require 'nokogiri'
require 'open-uri'

# Scraper for Ruby Gem datas from RubyGems.org
class RubyGemsScraper
  @ruby_gems_base_url = 'https://rubygems.org'
  @curr_gem_doc = nil

  class << self
    # Iterates through entire alphabet of pagination of rubygems.org's gems
    # and sends each page to check_ruby_gems_org to update/create gems/gem data
    def upsert_gems(gem_max = Float::INFINITY)
      alphabet = ('A'..'Z').to_a
      current_letter_path = "/gems?letter="

      alphabet.each do |letter|
        pagination_num = 1
        gem_max_exceeded = false
        loop do
          doc = Nokogiri::HTML(open(@ruby_gems_base_url + current_letter_path + letter + "&page=#{pagination_num}"))
          parse_page(doc)

          if gem_max != Float::INFINITY
            if gem_max <= RubyGem.count
              gem_max_exceeded = true
              break
            end
          end
          pagination_num += 1
          break if doc.css('.next_page.disabled').any?
        end

        break if gem_max_exceeded
      end
    end

    private

    # Finds all gems on a given page and checks for new gems and updates
    # existing ones with the following data:
    # - name
    # - url (github)
    # - downloads
    #
    # doc: Nokogiri HTML document of a pagination result of rubygems.org
    #
    def parse_page(doc)
      doc.css('a.gems__gem').each do |gem_link|
        @curr_gem_doc = Nokogiri::HTML(open(@ruby_gems_base_url + gem_link['href'])) # /gems/gem_name

        if github_url.length > 0
          if RubyGem.exists?(name: gem_name)
            RubyGem.update(name: gem_name, url: github_url, downloads: gem_downloads)
          else
            RubyGem.create(name: gem_name, url: github_url, downloads: gem_downloads)
          end
        end
      end
    rescue OpenURI::HTTPError => e
      # TODO: Fix logging
      puts e.message
    end

    def gem_name
      @curr_gem_doc.css('h1 a')[0].text.strip
    end

    def gem_downloads
      @curr_gem_doc.css('.gem__downloads')[0].text.strip.gsub(',', '')
    end

    def github_url
      home = @curr_gem_doc.css('#home')
      source = @curr_gem_doc.css('#code')

      url = ""
      valid_url = /http(s)?:\/\/github\.com/
      if home.any? && home[0]['href'][valid_url]
        url = home[0]['href']
      elsif source.any? && source[0]['href'][valid_url]
        url = source[0]['href']
      end

      # Make all http urls be https
      if url != "" && url[4] != "s"
        url.insert(4, "s")
      end

      url
    end
  end
end

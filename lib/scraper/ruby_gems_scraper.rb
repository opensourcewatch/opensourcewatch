require 'nokogiri'
require 'open-uri'
require 'httplog'

# Scraper for Ruby Gem data from RubyGems.org
class RubyGemsScraper
  @ruby_gems_base_url = 'https://rubygems.org'
  @curr_gem_doc = nil
  @upsert_limit = nil
  @letters_to_traverse = nil

  class << self
    # Iterates through entire alphabet of pagination of rubygems.org's gems
    # and sends each page to check_ruby_gems_org to update/create gems/gem data
    #
    # upsert_limit: number of upserts to perform
    def upsert_all_gems(letters_to_traverse: ("A".."Z").to_a, upsert_limit: Float::INFINITY)
      puts "Starting RubyGem's Upsert"

      @upsert_limit = upsert_limit
      @letters_to_traverse = letters_to_traverse

      catch :upsert_limit_reached do
        @letters_to_traverse.each do |letter|
          traverse_letter_pagination(letter)
        end
      end
    end

    # Special path using ruby gems stats page
    def upsert_top_100_gems
      page_number = 1
      while page_number <= 10 do
        stats_page_url = @ruby_gems_base_url + "/stats?page=#{page_number}"
        doc = Nokogiri::HTML(open(stats_page_url))

        # TODO: refactor this is almost identical to pagination of all ruby gems
        doc.css('.stats__graph__gem__name a').each do |gem_link|
          @curr_gem_doc = Nokogiri::HTML(open(@ruby_gems_base_url + gem_link['href'])) # /gems/gem_name

          if github_url.length > 0
            if RubyGem.exists?(name: gem_name)
              RubyGem.update(name: gem_name, url: github_url, downloads: gem_downloads)
              puts "UPDATED Gem #{gem_name}"
            else
              # binding.pry
              RubyGem.create(name: gem_name, url: github_url, downloads: gem_downloads)
              puts "CREATED Gem #{gem_name}."
            end
          else
            puts "SKIP Gem with URL #{@ruby_gems_base_url + gem_link['href']}: no Github URL found."
          end
        end

        page_number += 1
      end
    end

    private

    # Traverses all pagination for a given letter
    def traverse_letter_pagination(letter)
      current_letter_path = "/gems?letter="
      pagination_num = 1

      loop do
        doc = Nokogiri::HTML(open(@ruby_gems_base_url + current_letter_path + letter + "&page=#{pagination_num}"))

        parse_gems_on_current_page(doc)

        pagination_num += 1
        break if end_of_letter_pagination(doc)
      end
    end

    def end_of_letter_pagination(doc)
      doc.css('.next_page.disabled').any?
    end

    # Finds all gems on a given page and checks for new gems and updates
    # existing ones with the following data:
    # - name
    # - url (github)
    # - downloads
    #
    # doc: Nokogiri HTML document of a pagination result of rubygems.org
    #
    def parse_gems_on_current_page(doc)
      doc.css('a.gems__gem').each do |gem_link|
        @curr_gem_doc = Nokogiri::HTML(open(@ruby_gems_base_url + gem_link['href'])) # /gems/gem_name

        if github_url.length > 0
          if RubyGem.exists?(name: gem_name)
            RubyGem.update(name: gem_name, url: github_url, downloads: gem_downloads)
            puts "UPDATED Gem #{gem_name}"
          else
            RubyGem.create(name: gem_name, url: github_url, downloads: gem_downloads)
            puts "CREATED Gem #{gem_name}."
          end
        else
          puts "SKIP Gem with URL #{@ruby_gems_base_url + gem_link['href']}: no Github URL found."
        end

        throw :upsert_limit_reached if upsert_limit_exceeded
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

      valid_url = /http(s)?:\/\/github\.com\/\w+\/\w+/
      url = if home.any? && home[0]['href'][valid_url]
              url = home[0]['href']
            elsif source.any? && source[0]['href'][valid_url]
              url = source[0]['href']
            else
              ''
            end

      # Make all http urls be https
      if url != "" && url[4] != "s"
        url.insert(4, "s")
      end
      url
    end

    def upsert_limit_exceeded
      @upsert_limit != Float::INFINITY && RubyGem.count >= @upsert_limit
    end
  end
end

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
        loop do
          doc = Nokogiri::HTML(open(@ruby_gems_base_url + current_letter_path + letter + "&page=#{pagination_num}"))
          parse_page(doc)

          if gem_max != Float::INFINITY
            exit if gem_max <= RubyGem.count
          end
          pagination_num += 1
          break if doc.css('.next_page.disabled').any?
        end
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
      if home.any? && home[0]['href'].include?('github')
        url = home[0]['href']
      elsif source.any? && source[0]['href'].include?('github')
        url = source[0]['href']
      end

      if url != "" && url[4] != "s"
        url.insert(4, "s")
      end

      url
    end
  end
end

# Scrapes data for Gems and Users on Github.com
class GithubScraper

  class << self
    # Gets the following:
    # - number of stars the project has
    # - raw README.md file
    #
    # Example project's Github url vs raw url
    # - Github: https://github.com/rspec/rspec/blob/master/README.md
    # - Raw: https://raw.githubusercontent.com/rspec/rspec/master/README.md
    def update_gem_github_data(gems)
      gems.each do |gem|
        begin
          github_doc = Nokogiri::HTML(open(gem.url))

          stars = github_doc.css('ul.pagehead-actions li:nth-child(2) .social-count').text.strip.gsub(',', '')
          # Possibly need for numbers
          # [/\d+\,\d+/]

          if github_doc.at('td span:contains("README")')
            raw_file_url = gem.url.gsub('github', 'raw.githubusercontent') + '/master/README.md'
            description = Nokogiri::HTML(open(raw_file_url)).css('body p').text
          else
            description = "Empty"
          end

          gem.update(stars: stars, description: description)
        rescue OpenURI::HTTPError => e
          gem.destroy
          puts e.message
        end
      end
    end

    # Retrieves the top 100 contributors for each RubyGem
    def all_gems_top_100_contributors

    end
  end
end

# RubyGemsScraper.upsert_gems(5)
GithubScraper.update_gem_github_data(RubyGem.all)
RubyGem.update_score

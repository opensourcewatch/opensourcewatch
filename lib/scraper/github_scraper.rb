require 'nokogiri'
require 'open-uri'

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
    def update_gem_data(gems)
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

require 'nokogiri'
require 'open-uri'

# Scrapes data for Gems and Users on Github.com
class GithubScraper
  @github_doc = nil
  @current_lib = nil

  class << self
    # Gets the following:
    # - number of stars the project has
    # - raw README.md file
    #
    # Example project's Github url vs raw url
    # - Github: https://github.com/rspec/rspec/blob/master/README.md
    # - Raw: https://raw.githubusercontent.com/rspec/rspec/master/README.md
    #
    # gems: gems whose repo data will be updated
    def update_gem_data(gems = RubyGem.all)
      gems.each do |gem|
        begin
          @current_lib = gem
          @github_doc = Nokogiri::HTML(open(@current_lib.url))

          gem.update(stars: repo_stars, description: repo_description)
        rescue OpenURI::HTTPError => e
          gem.destroy
          puts e.message
        end
      end
    end

    # Retrieves the top contributors for each RubyGem
    def gem_contributors(gems = RubyGem.all)
      # gems.each do |gem|
      #   @github_doc =
      # end
    end

    private

    def repo_description
      if @github_doc.at('td span:contains("README")')
        raw_file_url = @current_lib.url.gsub('github', 'raw.githubusercontent') \
                          + '/master/README.md'
        Nokogiri::HTML(open(raw_file_url)).css('body p').text
      else
        "Empty"
      end
    end

    def repo_stars
      @github_doc.css('ul.pagehead-actions li:nth-child(2) .social-count')
        .text.strip.gsub(',', '')
    end
  end
end

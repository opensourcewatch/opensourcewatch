require 'nokogiri'
require 'open-uri'

# Scrapes data for Gems and Users on Github.com
class GithubScraper
  @github_doc = nil
  @current_lib = nil

  class << self
    attr_reader :github_doc
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

          # TODO: add to update_gem_data to get repo name and owner name
          # owner, repo_name = @current_lib.url[/\/\w+\/\w+/].split('/)

          gem.update(stars: repo_stars, description: repo_description)
        rescue OpenURI::HTTPError => e
          gem.destroy
          puts e.message
        end
      end
    end

    # Retrieves the top contributors for each RubyGem
    def lib_contributors(gems = RubyGem.all)
      gems.each do |gem|
        @current_lib = gem
        contr_path = @current_lib.url + '/graphs/contributors'
        @github_doc = Nokogiri::HTML(open(contr_path))
        binding.pry
        @github_doc.css('.capped-card').each do |dev_card|
          binding.pry
        end
      end
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

GithubScraper.lib_contributors(RubyGem.first(5))
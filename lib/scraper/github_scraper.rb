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
          puts "Gem #{gem.name} destroyed : its Github URL #{gem.url} resulted in #{e.message}"
        end
      end
    end

    # Retrieves the top contributors for each RubyGem
    #
    # NOTE: that you can use these both at the same time
    # options:
    # libraries: libraries whose repos will be scraped for data
    # page_limit: maximum number of pages to iterate
    # user_limit: max number of users to add
    def lib_contributors(scrape_limit_opts={})
      handle_scrape_limits(scrape_limit_opts)
      catch :scrape_limit_reached do
        @libraries.each do |lib|
          @current_lib = lib
          contr_path = @current_lib.url + '/commits/master'
          @github_doc = Nokogiri::HTML(open(contr_path))
          traverse_pagination
          @page_limit
        end
      end
    end
    # 2 agents for user data and stars/followers data

    private

    # this can be added to the other scraper
    def handle_scrape_limits(opts={})
      @libraries = opts[:libraries] || RubyGem.all
      @page_limit = opts[:page_limit] || Float::INFINITY
      @user_limit = opts[:user_limit] || Float::INFINITY
    end

    def traverse_pagination
      page_count = 1
      loop do
        fetch_commit_data

        throw :scrape_limit_reached if page_count >= @page_limit
        break unless @github_doc.css('.pagination').any?
        page_count += 1

        next_path = @github_doc.css('.pagination a')[0]['href']
        @github_doc = Nokogiri::HTML(open('https://github.com' + next_path))
      end
    end

    def fetch_commit_data
      @github_doc.css('.commit').each do |commit_info|
        # Not all avatars are users
        user_anchor = commit_info.css('.commit-avatar-cell a')[0]
        github_username = user_anchor['href'][1..-1] if user_anchor

        if User.where(github_username: github_username).count == 0 && !github_username.nil?
          user = User.create(github_username: github_username)
          puts "User with github_username:#{user.github_username} created."
        end

        throw :scrape_limit_reached if User.count >= @user_limit
      end
    end

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

# GithubScraper.lib_contributors(RubyGem.first(5))
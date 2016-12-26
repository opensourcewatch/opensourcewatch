# Get all gems from github
task "scrape:gems" => :environment do 
  require_relative "../scraper/ruby_gems_scraper"
  RubyGemsScraper.upsert_gems
end

# Get github repo information for each gem
task "scrape:github" => :environment do 
  require_relative "../scraper/github_scraper"
  GithubScraper.update_gem_data
end

# Get contributor info from each repo
task "scrape:contrib" => :environment do
  require_relative "../scraper/github_scraper" 
  GithubScraper.lib_contributors
end

task "gems:gscores" => :environment do 
  RubyGem.update_score
end

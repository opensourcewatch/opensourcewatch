namespace :scrape do 
  # Get all gems from github
  task :gems, [:letters, :upsert_limit] => :environment do |t, args|
    binding.pry
    require_relative "../scraper/ruby_gems_scraper"
    RubyGemsScraper.upsert_gems
  end

  # Get github repo information for each gem
  task :github => :environment do 
    require_relative "../scraper/github_scraper"
    GithubScraper.update_gem_data
  end

  # Get contributor info from each repo
  task :contrib => :environment do
    require_relative "../scraper/github_scraper" 
    GithubScraper.lib_contributors
  end

  task :all => ["scrape:gems", "scrape:github", "scrape:contrib"]
end

task "gems:gscores" => :environment do 
  RubyGem.update_score
end


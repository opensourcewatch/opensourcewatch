namespace :scrape do 
  # Get all gems from github
  # Can call for a single letter and x amount of gems:
  #   ex. rake scrape:gems[F, 20]
  task :gems, [:letters_to_traverse, :upsert_limit] => :environment do |t, args|
    require_relative "../scraper/ruby_gems_scraper"

    options = args.to_h
    if args.letters_to_traverse
      options[:letters_to_traverse] = args.letters_to_traverse.split(" ")
    end

    RubyGemsScraper.upsert_gems(options)
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


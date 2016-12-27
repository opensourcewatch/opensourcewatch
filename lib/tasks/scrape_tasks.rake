namespace :ruby_gems do 
  require_relative "../scraper/ruby_gems_scraper"

  # Get all gems from ruby gems
  # Can call for a single letter and x amount of gems:
  #   ex. rake scrape:gems[F, 20]
  task :gems, [:letters_to_traverse, :upsert_limit] => :environment do |t, args|
    options = args.to_h
    if args.letters_to_traverse
      options[:letters_to_traverse] = args.letters_to_traverse.split(" ")
    end

    RubyGemsScraper.upsert_gems(options)
  end
end

namespace :github do
  require_relative "../scraper/github_scraper"

  # Get github repo information for each gem
  task :gems => :environment do 
    GithubScraper.update_gem_data
  end

  # Get contributor info from each repo
  task :contributors => :environment do
    GithubScraper.lib_contributors
    GithubScraper.update_user_data
  end

  task :all => [:gems, :contributors]
end

task "scrape:all" => ["ruby_gems:gems", "github:all"]

task "gems:gscores" => :environment do 
  RubyGem.update_score
end


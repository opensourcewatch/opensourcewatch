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

    babysitter do 
      RubyGemsScraper.upsert_gems(options)
    end
  end

  task :top_100 => :environment do 
    babysitter do 
      RubyGemsScraper.upsert_top_100_gems
    end
  end
end

namespace :github do
  require_relative "../scraper/github_scraper"

  # Get github repo information for each gem
  task :gems => :environment do 
    babysitter do 
      GithubScraper.update_gem_data
    end
  end

  # Get contributor info from each repo
  task :contributors => :environment do
    babysitter do 
      GithubScraper.lib_contributors
      GithubScraper.update_user_data
    end
  end

  task :all => [:gems, :contributors]
end

task "scrape:all" => ["ruby_gems:gems", "github:all"]

task "gems:gscores" => :environment do 
  RubyGem.update_score
end

def babysitter
  start_time = Time.now

  begin
    yield
  rescue Exception => e
    puts "ERROR: #{e.message}"
  end

  finish_time = Time.now
  puts "Task began at #{start_time} and finished #{(finish_time - start_time).seconds} seconds later at #{finish_time} "
end
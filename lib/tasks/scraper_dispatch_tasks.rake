# Get commit info from each repo using the redis queue
namespace :dispatch do
  require_relative '../scraper/scraper_dispatcher'
  require_relative '../scraper/github_repo_scraper'

  task :commits => :environment do |t|
    babysitter(t) do
      puts "Dispatching commits and issues scraping pathway..."
      ScraperDispatcher.scrape_commits
    end
  end

  task :issues => :environment do |t|
    babysitter(t) do
      puts "Dispatching commits and issues scraping pathway..."
      ScraperDispatcher.scrape_issues
    end
  end

  task :metadata => :environment do |t|
    babysitter(t) do
      puts "Dispatching agent to work on blank repositories scraping metadata..."
      ScraperDispatcher.scrape_metadata
    end
  end

  task :redis_requeue, [:queue_name, :query] => :environment do |t, args|
    puts "Enqueuing redis..."
    ScraperDispatcher.redis_requeue(args.to_h)
  end
end

# Get commit info from each repo using the redis queue
namespace :dispatch do
  require_relative '../scraper/scraper_dispatcher'
  require_relative '../scraper/github_repo_scraper'

  task :commits => :environment do |t|
    puts "Dispatching commits and issues scraping pathway..."
    ScraperDispatcher.scrape
  end

  task :issues => :environment do |t|
    puts "Dispatching issues scraping pathway..."
    ScraperDispatcher.scrape
  end

  task :metadata => :environment do |t|
    puts "Dispatching agent to work on blank repositories scraping metadata..."
    ScraperDispatcher.scrape
  end
end

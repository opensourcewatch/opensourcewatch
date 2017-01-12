# Get commit info from each repo using the redis queue
namespace :dispatch do
  require_relative '../scraper/scraper_dispatcher'
  require_relative '../scraper/github_repo_scraper'

  task :priority_commits => :environment do |t|
    puts "Dispatching priority commits scraping pathway..."
    ScraperDispatcher.scrape(queue_name: "prioritized_repositories")
  end

  task :commits => :environment do |t|
    puts "Dispatching commits scraping pathway..."
    ScraperDispatcher.scrape
  end

  task :issues => :environment do |t|
    puts "Dispatching commits and issues scraping pathway..."
    ScraperDispatcher.scrape(commits_on: false, issues_on: true)
  end

  task :metadata => :environment do |t|
    puts "Dispatching agent to work on blank repositories scraping metadata..."
    ScraperDispatcher.scrape(queue_name: 'blank_repositories')
  end
end

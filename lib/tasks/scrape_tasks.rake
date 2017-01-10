# Not your comments anymore

namespace :github do
  require_relative "../scraper/github_repo_scraper"
  require_relative "../scraper/github_user_scraper"

  # Get github repo information for each repo
  task :repos => :environment do |t|
    babysitter(t) do
      GithubRepoScraper.update_repo_data
    end
  end

  task :users => :environment do |t|
    GithubUserScraper.update_user_data
  end

  # Get commit info from each repo
  # TODO: make args take in the 3 options for lib_commits
  task :commits, [:infinite, :fetch_meta] => :environment do |t, args|
    if args.infinite == "true"
      babysitter(t) do
        loop do
          GithubRepoScraper.commits({}, args.fetch_meta)
        end
      end
    else
      babysitter(t) do
        GithubRepoScraper.commits({}, args.fetch_meta)
      end
    end
  end

  task :issues, [:infinite, :fetch_meta]  => :environment do |t, args|
    if args.infinite == "true"
      loop do
        GithubRepoScraper.issues
      end
    else
      GithubRepoScraper.issues({}, args.fetch_meta)
    end
  end

  task :all => [:repos, :commits, :issues, :users]
end

# Get commit info from each repo using the redis queue
namespace :dispatch do
  require_relative '../scraper/scraper_dispatcher'
  require_relative '../scraper/github_repo_scraper'

  task :repo_activity => :environment do |t|
    babysitter(t) do
      puts "Dispatching commits and issues scraping pathway..."
      ScraperDispatcher.repo_activity
    end
  end

  task :redis_requeue => :environment do
    puts "Enqueuing redis..."
    ScraperDispatcher.redis_requeue
  end
end

namespace :github_api do
  task :search_repos, [:skip_to_star] => :environment do |t, args|
    require_relative '../api/github_search_wrapper.rb'

    GithubSearchWrapper.paginate_repos(args.to_h)
  end

  task :public_repos, [:start_id, :stop_id] => :environment do |t, args|
    require_relative '../api/github_repos_wrapper'

    GithubReposWrapper.paginate_repos(args.to_h)
  end
end

def babysitter(task = NullTask.new)
  # Handles additional logging and error handling for the task
  start_time = Time.now
  begin
    yield
  rescue Exception => e
    completion_message = "Task #{task.name} completed ? FALSE : ERROR #{e.message}"
  end
  finish_time = Time.now

  completion_message = "Task complethttps://ruby-doc.org/core-2.2.0/File.htmlred ? TRUE" unless completion_message

  HttpLog.log(tag_meta("NAME: " + task.name))
  HttpLog.log(tag_meta("EXITED: " + completion_message))
  HttpLog.log(tag_meta("RUNTIME: #{(finish_time - start_time).seconds} seconds"))
  HttpLog.log(tag_meta("START: #{start_time}"))
  HttpLog.log(tag_meta("FINISH: #{finish_time}"))
  HttpLog.log(tag_meta("__END_OF_REQUEST_SEQUENCE__"))
  RequestsLogReport.present
end

def tag_meta(str)
  "|META| #{str}"
end

class NullTask
  attr_accessor :name, :desc

  def initialize
    @name = "UNNAMED"
    @desc = "NO DESCRIPTION"
  end
end

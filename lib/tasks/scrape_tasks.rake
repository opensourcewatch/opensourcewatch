# For local testing with small amounts of repos
namespace :github do
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

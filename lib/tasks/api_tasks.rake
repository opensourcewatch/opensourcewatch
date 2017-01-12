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

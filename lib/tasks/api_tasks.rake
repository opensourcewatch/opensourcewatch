namespace :github_api do
  task :search_repos, [:skip_to_star] => :environment do |t, args|
    GithubSearchWrapper.paginate_repos(args.to_h)
  end

  task :public_repos, [:start_id, :stop_id] => :environment do |t, args|
    GithubReposWrapper.paginate_repos(args.to_h)
  end
end

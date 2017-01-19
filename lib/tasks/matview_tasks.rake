task :update_repo_activity_last_90_view => :environment do
  require 'repo_activity_matview_last_90'
  RepoActivityMatviewLast90.refresh
end

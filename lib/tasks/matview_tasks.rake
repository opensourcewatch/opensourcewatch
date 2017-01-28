task :refresh_matviews => :environment do
begin
  Matviews::IssueActivity::Last0.refresh;
  Matviews::IssueActivity::Last7.refresh;
  Matviews::IssueActivity::Last30.refresh;
  Matviews::IssueActivity::Last90.refresh;
  Matviews::RepoActivity::Last0.refresh;
  Matviews::RepoActivity::Last7.refresh;
  Matviews::RepoActivity::Last30.refresh;
  Matviews::RepoActivity::Last90.refresh;
  Matviews::TopUser::Last0.refresh;
  Matviews::TopUser::Last7.refresh;
  Matviews::TopUser::Last30.refresh;
  Matviews::TopUser::Last90.refresh;
  Matviews::ChattiestUser::Last0.refresh;
  Matviews::ChattiestUser::Last7.refresh;
  Matviews::ChattiestUser::Last30.refresh;
  Matviews::ChattiestUser::Last90.refresh;
rescue Exception => e
  user = `echo $USER`.chomp
  File.open('/home/#{user}/workspace/capstone/log/cron.log', "a+") do |f|
    f.write(e.message)
    f.write(e.backtrace)
  end
end
end

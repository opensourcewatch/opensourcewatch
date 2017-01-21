# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 2.minutes do
  runner "Matviews::IssueActivityLast0.refresh"
  runner "Matviews::IssueActivityLast7.refresh"
  runner "Matviews::IssueActivityLast30.refresh"
  runner "Matviews::IssueActivityLast90.refresh"

  runner "Matviews::RepoActivityLast0.refresh"
  runner "Matviews::RepoActivityLast7.refresh"
  runner "Matviews::RepoActivityLast30.refresh"
  runner "Matviews::RepoActivityLast90.refresh"

  runner "Matviews::TopUserLast0.refresh"
  runner "Matviews::TopUserLast7.refresh"
  runner "Matviews::TopUserLast30.refresh"
  runner "Matviews::TopUserLast90.refresh"

  runner "Matviews::ChattiestUserLast0.refresh"
  runner "Matviews::ChattiestUserLast7.refresh"
  runner "Matviews::ChattiestUserLast30.refresh"
  runner "Matviews::ChattiestUserLast90.refresh"
end

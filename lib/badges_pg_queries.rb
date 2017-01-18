# Note: In order for this script to work you must enter the pw when prompted OR
# create a .pgpass file in the root directory containing a line like:
# hostname:port:database_name:username:password for more information see:
# https://www.postgresql.org/docs/8.3/static/libpq-pgpass.html
def query(sql)
  cmd = "psql -h 104.236.81.65 -p 5432 -U postgres -d curation_development -c"

  run = cmd + " " + sql
  puts run

  return_value = `#{run}`
  puts return_value

  execution_time = return_value.match(/Execution time: \d+.\d+/)[0].match(/\d+.\d+/)[0].to_f
  $sum += execution_time
end

$query_times = []
def benchmark(resource)
  resource.keys.each do |key|
    $sum = 0
    5.times do
      query(resource[key])
    end

    $query_times << ($sum/5.0)
  end
end

base = {
  all: "",
  daily: "",
  weekly: "",
  monthly: "",
}

today = Date.today
midnight = " 00:00:00"
end_of_day = " 23:59:59.99"

day = today.strftime("%Y-%m-%d")
beg_day = day + midnight
end_day = day + end_of_day

last_week = (today - 7).strftime("%Y-%m-%d")
beg_week = last_week + midnight
end_week = last_week + end_of_day

last_month = (today - 30).strftime("%Y-%m-%d")
beg_month = last_month + midnight
end_month = last_month + end_of_day

repo = base.clone
repo[:all]    = "\"EXPLAIN ANALYZE SELECT  repositories.*, count(repositories.id) as hit_count FROM \"repositories\" INNER JOIN \"commits\" ON \"commits\".\"repository_id\" = \"repositories\".\"id\" GROUP BY repositories.id ORDER BY hit_count DESC LIMIT 5\""
repo[:daily]  = "\"EXPLAIN ANALYZE SELECT  repositories.id, repositories.name, count(repositories.id) AS hit_count FROM \"repositories\" INNER JOIN commits ON commits.repository_id = repositories.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_day}' AND '#{end_day}') GROUP BY repositories.id ORDER BY hit_count desc LIMIT 5\""
repo[:weekly] = "\"EXPLAIN ANALYZE SELECT  repositories.id, repositories.name, count(repositories.id) AS hit_count FROM \"repositories\" INNER JOIN commits ON commits.repository_id = repositories.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_week}' AND '#{end_week}') GROUP BY repositories.id ORDER BY hit_count desc LIMIT 5\""
repo[:monthly] = "\"EXPLAIN ANALYZE SELECT  repositories.id, repositories.name, count(repositories.id) AS hit_count FROM \"repositories\" INNER JOIN commits ON commits.repository_id = repositories.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_month}' AND '#{end_month}') GROUP BY repositories.id ORDER BY hit_count desc LIMIT 5\""

issue = base.clone
issue[:all]     = "\"EXPLAIN ANALYZE SELECT  issues.id, issues.name, count(issues.id) AS hit_count FROM \"issues\" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id GROUP BY issues.id ORDER BY hit_count desc LIMIT 5\""
issue[:daily]   = "\"EXPLAIN ANALYZE SELECT  issues.id, issues.name, count(issues.id) AS hit_count FROM \"issues\" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_day}' AND '#{end_day}') GROUP BY issues.id ORDER BY hit_count desc LIMIT 5\""
issue[:weekly]  = "\"EXPLAIN ANALYZE SELECT  issues.id, issues.name, count(issues.id) AS hit_count FROM \"issues\" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_week}' AND '#{end_week}') GROUP BY issues.id ORDER BY hit_count desc LIMIT 5\""
issue[:monthly] = "\"EXPLAIN ANALYZE SELECT  issues.id, issues.name, count(issues.id) AS hit_count FROM \"issues\" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_month}' AND '#{end_month}') GROUP BY issues.id ORDER BY hit_count desc LIMIT 5\""

user_commits = base.clone
user_commits[:all]     = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN commits ON commits.user_id = users.id GROUP BY users.id ORDER BY hit_count desc LIMIT 5\""
user_commits[:daily]   = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN commits ON commits.user_id = users.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_day}' AND '#{end_day}') GROUP BY users.id ORDER BY hit_count desc LIMIT 5\""
user_commits[:weekly]  = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN commits ON commits.user_id = users.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_week}' AND '#{end_week}') GROUP BY users.id ORDER BY hit_count desc LIMIT 5\""
user_commits[:monthly] = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN commits ON commits.user_id = users.id WHERE (\"commits\".\"github_created_at\" BETWEEN '#{beg_month}' AND '#{end_month}') GROUP BY users.id ORDER BY hit_count desc LIMIT 5\""

user_comments = base.clone
user_comments[:all]     = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN issue_comments ON issue_comments.user_id = users.id GROUP BY users.id ORDER BY hit_count desc LIMIT 1\""
user_comments[:daily]   = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN issue_comments ON issue_comments.user_id = users.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_day}' AND '#{end_day}') GROUP BY users.id ORDER BY hit_count desc LIMIT 1\""
user_comments[:weekly]  = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN issue_comments ON issue_comments.user_id = users.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_week}' AND '#{end_week}') GROUP BY users.id ORDER BY hit_count desc LIMIT 1\""
user_comments[:monthly] = "\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN issue_comments ON issue_comments.user_id = users.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN '#{beg_month}' AND '#{end_month}') GROUP BY users.id ORDER BY hit_count desc LIMIT 1\""

benchmark(repo)
benchmark(issue)
benchmark(user_commits)
benchmark(user_comments)

puts $query_times

require 'benchmark'
$SUM = 0

def benchmark(name)
  start = Time.now
  yield
  stop = Time.now
  diff = stop - start
  $SUM += diff
  puts "#{name} in #{diff}"
end

def section(tag)
  puts
  puts tag
  puts "-------"
  puts
end

query_type =  [
                "Most_Active Repo",
                "Most Commented Issue",
                "Most Active Users",
                "Chattiest Users"
              ]

#####################
##### All Time ######
#####################

section("ALL TIME")

benchmark(query_type[0]) do
  Repository.select("repositories.*, count(commits.id) as commit_count").
    joins(:commits).group('repositories.id').order("commit_count DESC").
    limit(5)
end

benchmark query_type[1] do
  Issue.select("issues.*, count(issue_comments.id) as comment_count").
    joins(:issue_comments).group('issues.id').
    order("comment_count DESC").limit(5)
end

benchmark query_type[2] do
  User.select("users.*, count(commits.id) as commit_count").
    joins(:commits).group('users.id').
    order("commit_count DESC").limit(5)
end

benchmark query_type[3] do
  User.select("users.*, count(issue_comments.id) as comment_count").
    joins(:issue_comments).group('users.id').
    order("comment_count DESC").limit(5)
end

##################
##### Today ######
##################

section("TODAY")

# Note dates should refer to the github created at time
date = Date.today
commits = Commit.where(github_created_at: date.midnight..date.end_of_day).count

##### Most popular repo ######

# Repos with the most commits on a certain day
# Filter the commits by the date
# Inner Join with repositories
# Count most duplications of repositories

# Most commits on given day - 460 ms
benchmark(query_type[0]) do
  Repository.select("repositories.id, repositories.name, count(repositories.id) AS hit_count").
    joins("INNER JOIN commits ON commits.repository_id = repositories.id").
    where('commits.github_created_at' => date.midnight..date.end_of_day).
    group('repositories.id').order("hit_count desc").limit(5)
end

##### Most Commented Issues ##### - 272.ms

benchmark(query_type[1]) do
  Issue.select("issues.id, issues.name, count(issues.id) AS hit_count").
    joins("INNER JOIN issue_comments ON issue_comments.issue_id = issues.id").
    where('issue_comments.github_created_at' => date.midnight..date.end_of_day).
    group('issues.id').order("hit_count desc").limit(1)
end

##### Most Active Users ######
benchmark(query_type[2]) do
  User.select("users.*, count(users.id) as hit_count").
    joins("INNER JOIN commits ON commits.user_id = users.id").
    where('commits.github_created_at' => date.midnight..date.end_of_day).
    group('users.id').order("hit_count desc").limit(1)
end

##### Chattiest Users ########
benchmark(query_type[3]) do
  User.select("users.*, count(users.id) as hit_count").
    joins("INNER JOIN issue_comments ON issue_comments.user_id = users.id").
    where('issue_comments.github_created_at' => date.midnight..date.end_of_day).
    group('users.id').order("hit_count desc").limit(1)
end

########################
###### Weekly #########
########################
section("WEEKLY")

start_date = Date.today - 7
end_date = Date.today

benchmark(query_type[0]) do
  Repository.select("repositories.id, repositories.name, count(repositories.id) AS hit_count").
    joins("INNER JOIN commits ON commits.repository_id = repositories.id").
    where('commits.github_created_at' => start_date..end_date).
    group('repositories.id').order("hit_count desc").limit(5)
end

benchmark(query_type[1]) do
  Issue.select("issues.id, issues.name, count(issues.id) AS hit_count").
    joins("INNER JOIN issue_comments ON issue_comments.issue_id = issues.id").
    where('commits.github_created_at' => start_date..end_date).
    group('issues.id').order("hit_count desc").limit(1)
end

##### Most Active Users ######
benchmark(query_type[2]) do
  User.select("users.*, count(users.id) as hit_count").
    joins("INNER JOIN commits ON commits.user_id = users.id").
    where('commits.github_created_at' => start_date..end_date).
    group('users.id').order("hit_count desc").limit(1)
end
##### Chattiest Users ########
benchmark(query_type[3]) do
  User.select("users.*, count(users.id) as hit_count").
    joins("INNER JOIN issue_comments ON issue_comments.user_id = users.id").
    where('issue_comments.github_created_at' => start_date..end_date).
    group('users.id').order("hit_count desc").limit(1)
end
########################
###### Monthly #########
########################

section("MONTHLY")

# Most Commits - 730 ms
start_date = Date.today - 30
end_date = Date.today

benchmark(query_type[0]) do
  Repository.select("repositories.id, repositories.name, count(repositories.id) AS hit_count").
    joins("INNER JOIN commits ON commits.repository_id = repositories.id").
    where('commits.github_created_at' => start_date..end_date).
    group('repositories.id').order("hit_count desc").limit(1)
end

benchmark(query_type[1]) do
  Issue.select("issues.id, issues.name, count(issues.id) AS hit_count").
    joins("INNER JOIN issue_comments ON issue_comments.issue_id = issues.id").
    where('issue_comments.github_created_at' => start_date..end_date).
    group('issues.id').order("hit_count desc").limit(1)
end

##### Most Active Users ######
benchmark(query_type[2]) do
  User.select("users.*, count(users.id) as hit_count").
    joins("INNER JOIN commits ON commits.user_id = users.id").
    where('commits.github_created_at' => start_date..end_date).
    group('users.id').order("hit_count desc").limit(1)
end

##### Chattiest Users ########
benchmark(query_type[3]) do
User.select("users.*, count(users.id) as hit_count").
  joins("INNER JOIN issue_comments ON issue_comments.user_id = users.id").
  where('issue_comments.github_created_at' => start_date..end_date).
  group('users.id').order("hit_count desc").limit(1)
end

section("SUMMARY")
puts "Total: #{$SUM}"

# Note: In order for this script to work you must enter the pw when prompted OR
# create a .pgpass file in the root directory containing a line like:
# hostname:port:database_name:username:password for more information see:
# https://www.postgresql.org/docs/8.3/static/libpq-pgpass.html

class Query
  BEG_OF_DAY = " 00:00:00"
  END_OF_DAY = " 23:59:59.99"
  TIME_FRAMES = [0, 7, 30, 90]

  def initialize(resource, base_query)
    @today = Date.today
    @end_day = end_day
    @summary = []
    @resource, @base_query = resource, base_query
  end

  def run_queries
    TIME_FRAMES.each do |window|
      @beg_day = calc_beg_day(window)
      sql = generate
      @summary << "#{@resource} last #{window} days: #{execute(sql)} ms"
    end
    puts @summary
  end

  private

  def generate
    @base_query[0] + range + @base_query[1]
  end

  def range
    "'#{@beg_day}' AND '#{@end_day}'"
  end

  def execute(sql)
    cmd = "psql -h 104.236.81.65 -p 5432 -U postgres -d curation_development -c"

    run = cmd + " " + sql
    puts run

    return_value = `#{run}`
    puts return_value

    execution_time = return_value.match(/Execution time: \d+.\d+/)[0].match(/\d+.\d+/)[0].to_f
  end

  def calc_beg_day(days)
    day = @today - days
    day = day.strftime("%Y-%m-%d")
    day + BEG_OF_DAY
  end

  def end_day
    day = @today.strftime("%Y-%m-%d")
    day + END_OF_DAY
  end
end

# Queries
#repo_all_time = "\"EXPLAIN ANALYZE SELECT  repositories.*, count(repositories.id) as hit_count FROM \"repositories\" INNER JOIN \"commits\" ON \"commits\".\"repository_id\" = \"repositories\".\"id\" GROUP BY repositories.id ORDER BY hit_count DESC LIMIT 5\""
repo_base_query = [ "\"EXPLAIN ANALYZE SELECT  repositories.id, repositories.name, count(repositories.id) AS hit_count FROM \"repositories\" INNER JOIN commits ON commits.repository_id = repositories.id WHERE (\"commits\".\"github_created_at\" BETWEEN ",
                    " ) GROUP BY repositories.id ORDER BY hit_count desc LIMIT 5\"" ]
repo_queries = Query.new("repository activity", repo_base_query)
repo_queries.run_queries

issue_base_query = ["\"EXPLAIN ANALYZE SELECT  issues.id, issues.name, count(issues.id) AS hit_count FROM \"issues\" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN ",
                    " ) GROUP BY issues.id ORDER BY hit_count desc LIMIT 5\""]
issue_queries = Query.new("issue activity", issue_base_query)
issue_queries.run_queries

user_commits_base_query  = ["\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN commits ON commits.user_id = users.id WHERE (\"commits\".\"github_created_at\" BETWEEN ",
                            " ) GROUP BY users.id ORDER BY hit_count desc LIMIT 5\""]
user_commits = Query.new('user activity', user_commits_base_query)
user_commits.run_queries

user_comments_base_query = ["\"EXPLAIN ANALYZE SELECT  users.*, count(users.id) as hit_count FROM \"users\" INNER JOIN issue_comments ON issue_comments.user_id = users.id WHERE (\"issue_comments\".\"github_created_at\" BETWEEN ",
                            " ) GROUP BY users.id ORDER BY hit_count desc LIMIT 1\""]
user_comments = Query.new('chattiest user', user_comments_base_query)
user_comments.run_queries

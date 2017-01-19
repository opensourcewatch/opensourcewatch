class AddCommitsMatview < ActiveRecord::Migration[5.0]

  def up
    name = "repo_activity_matview_last_90"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT  repositories.id, repositories.name, count(repositories.id) AS hit_count
        FROM "repositories" INNER JOIN commits ON commits.repository_id = repositories.id
        WHERE ("commits"."github_created_at" BETWEEN '2016-10-20 00:00:00' AND '2017-01-18 23:59:59.99' )
        GROUP BY repositories.id ORDER BY hit_count desc LIMIT 5;
    SQL
  end

  def down
    raise Exception.new("Does not know how to revert")
  end
end

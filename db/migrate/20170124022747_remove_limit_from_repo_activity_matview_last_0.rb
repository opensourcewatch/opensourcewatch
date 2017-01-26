class RemoveLimitFromRepoActivityMatviewLast0 < ActiveRecord::Migration[5.0]
  def up
    name = "repo_activity_matview_last_0"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT  repositories.*, count(repositories.id) AS hit_count
        FROM "repositories" INNER JOIN commits ON commits.repository_id = repositories.id
        WHERE ("commits"."github_created_at" BETWEEN (CURRENT_DATE - INTERVAL '0 day' + TIME '00:00:00') AND (CURRENT_DATE + TIME '23:59:59.99') )
        GROUP BY repositories.id ORDER BY hit_count desc;
    SQL
  end

  def down
    raise Exception.new("Does not know how to revert")
  end
end

class CreateIssueActivityMatviewAfterOpenDateColumnRemovalCascade < ActiveRecord::Migration[5.0]
  def up
    name = "issue_activity_matview_last_0"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT issues.*, count(issues.id) AS hit_count
        FROM "issues" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id
        WHERE ("issue_comments"."github_created_at" BETWEEN (CURRENT_DATE - INTERVAL '0 day' + TIME '00:00:00') AND (CURRENT_DATE + TIME '23:59:59.99') )
        GROUP BY issues.id ORDER BY hit_count desc;
    SQL

    name = "issue_activity_matview_last_7"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT issues.*, count(issues.id) AS hit_count
        FROM "issues" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id
        WHERE ("issue_comments"."github_created_at" BETWEEN (CURRENT_DATE - INTERVAL '7 day' + TIME '00:00:00') AND (CURRENT_DATE + TIME '23:59:59.99') )
        GROUP BY issues.id ORDER BY hit_count desc;
    SQL

    name = "issue_activity_matview_last_30"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT issues.*, count(issues.id) AS hit_count
        FROM "issues" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id
        WHERE ("issue_comments"."github_created_at" BETWEEN (CURRENT_DATE - INTERVAL '30 day' + TIME '00:00:00') AND (CURRENT_DATE + TIME '23:59:59.99') )
        GROUP BY issues.id ORDER BY hit_count desc;
    SQL

    name = "issue_activity_matview_last_90"
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{name};
      CREATE MATERIALIZED VIEW #{name} AS
        SELECT issues.*, count(issues.id) AS hit_count
        FROM "issues" INNER JOIN issue_comments ON issue_comments.issue_id = issues.id
        WHERE ("issue_comments"."github_created_at" BETWEEN (CURRENT_DATE - INTERVAL '90 day' + TIME '00:00:00') AND (CURRENT_DATE + TIME '23:59:59.99') )
        GROUP BY issues.id ORDER BY hit_count desc;
    SQL
  end

  def down
    raise Exception.new("Does not know how to revert")
  end
end

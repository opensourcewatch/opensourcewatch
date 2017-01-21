class AddValidationToIssueCommentsAtDbLayer < ActiveRecord::Migration[5.0]
  def up
    name = 'github_created_at_uniqueness'
    execute <<-SQL
      ALTER TABLE issue_comments DROP CONSTRAINT IF EXISTS #{name};
      ALTER TABLE issue_comments ADD CONSTRAINT github_created_at_uniqueness UNIQUE (github_created_at, user_id, issue_id);
    SQL
  end
end

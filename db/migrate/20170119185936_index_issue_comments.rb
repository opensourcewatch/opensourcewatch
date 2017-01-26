class IndexIssueComments < ActiveRecord::Migration[5.0]
  def change
    add_index :issue_comments, :github_created_at
  end
end

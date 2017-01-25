class MakeIssueIdAnIndexInIssueComments < ActiveRecord::Migration[5.0]
  def change
    add_index :issue_comments, :issue_id
  end
end

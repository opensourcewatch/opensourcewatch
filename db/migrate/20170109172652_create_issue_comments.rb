class CreateIssueComments < ActiveRecord::Migration[5.0]
  def change
    create_table :issue_comments do |t|
      t.integer :user_id, :issue_id
      t.text :body
      t.datetime :github_created_at
      t.timestamps
    end
  end
end

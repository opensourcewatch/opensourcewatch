class AddFkIndexes < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :commits, :users, column: :user_id
    add_foreign_key :commits, :repositories, column: :repository_id

    add_foreign_key :issue_comments, :issues, column: :user_id

    add_foreign_key :issues, :repositories, column: :repository_id
  end
end

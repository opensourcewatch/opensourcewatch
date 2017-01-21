class AddIndexesToCommitsAndUsers < ActiveRecord::Migration[5.0]
  def change
    add_index(:users, :github_username)
    add_index(:commits, :github_identifier)
  end
end

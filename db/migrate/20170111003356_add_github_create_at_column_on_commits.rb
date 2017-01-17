class AddGithubCreateAtColumnOnCommits < ActiveRecord::Migration[5.0]
  def change
    add_column :commits, :github_created_at, :datetime
  end
end

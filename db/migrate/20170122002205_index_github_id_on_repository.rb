class IndexGithubIdOnRepository < ActiveRecord::Migration[5.0]
  def change
    add_index :repositories, :github_id
  end
end

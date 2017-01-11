class AddOpenIssuesToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :open_issues, :integer
  end
end

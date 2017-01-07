class AddScoreColumnToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :score, :integer
  end
end

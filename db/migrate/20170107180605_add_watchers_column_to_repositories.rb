class AddWatchersColumnToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :watchers, :integer 
  end
end

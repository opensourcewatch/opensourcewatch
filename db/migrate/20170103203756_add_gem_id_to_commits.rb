class AddGemIdToCommits < ActiveRecord::Migration[5.0]
  def change
    add_column :commits, :gem_id, :integer
  end
end

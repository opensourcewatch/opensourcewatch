class RenameGemIdFkOnCommits < ActiveRecord::Migration[5.0]
  def change
    rename_column :commits, :gem_id, :ruby_gem_id
  end
end

class RenameRubyGemFkInCommitsTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :commits, :ruby_gem_id, :repository_id
  end
end

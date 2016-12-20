class RenameGems < ActiveRecord::Migration[5.0]
  def change
    rename_table :gems, :ruby_gems
  end
end

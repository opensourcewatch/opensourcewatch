class CreateGems < ActiveRecord::Migration[5.0]
  def change
    create_table :gems do |t|
      t.string :url, :name
      t.integer :downloads
      t.timestamps
    end
  end
end

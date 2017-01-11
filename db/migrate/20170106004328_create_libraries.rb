class CreateLibraries < ActiveRecord::Migration[5.0]
  def change
    create_table :libraries do |t|
      t.string :name
      t.integer :github_id
      t.string :url, :language
      t.integer :stars, :forks
      t.timestamps
    end
  end
end

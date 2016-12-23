class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :github_username
      t.string :email
      t.integer :stars
      t.integer :followers
      t.float :score
      t.timestamps
    end
  end
end

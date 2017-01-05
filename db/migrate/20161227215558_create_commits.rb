class CreateCommits < ActiveRecord::Migration[5.0]
  def change
    create_table :commits do |t|
      t.string :message
      t.integer :user_id
      t.timestamps
    end
  end
end

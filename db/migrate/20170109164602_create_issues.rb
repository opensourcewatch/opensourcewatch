class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.integer :repository_id
      t.string :name, :creator, :url, :open_date
      t.integer :issue_number
    end
  end
end

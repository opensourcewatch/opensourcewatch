class AddIdentifierColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :commits, :github_identifier, :string
  end
end

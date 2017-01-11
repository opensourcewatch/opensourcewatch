class AddTimestampsToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column(:issues, :created_at, :datetime)
    add_column(:issues, :updated_at, :datetime)
  end
end

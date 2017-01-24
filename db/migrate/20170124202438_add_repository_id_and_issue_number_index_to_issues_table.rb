class AddRepositoryIdAndIssueNumberIndexToIssuesTable < ActiveRecord::Migration[5.0]
  def change
    add_index :issues, [:issue_number, :repository_id]
  end
end

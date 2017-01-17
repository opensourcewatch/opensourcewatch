class IssueComment < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user

  validates :github_created_at, uniqueness: { scope: [:issue_id] }
end

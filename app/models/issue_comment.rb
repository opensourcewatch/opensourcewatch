class IssueComment < ActiveRecord::Base
  belongs_to :issue

  validates :github_created_at, uniqueness: { scope: [:issue_id] }
end

class User < ActiveRecord::Base
  # TODO: User is the wrong name. This should be github_accounts, open_sourcerers, or developers,
  # but not user. We will probably want to have a user for our app eventually that
  # is separate from github user account info.
  validates :github_username, uniqueness: true

  has_many :commits
  has_many :issue_comments
end

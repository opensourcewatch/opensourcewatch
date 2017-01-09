class User < ActiveRecord::Base
  # TODO: why does a user have a name AND a github_username ? 
  validates :github_username, uniqueness: true

  has_many :commits
  has_many :issue_comments
end

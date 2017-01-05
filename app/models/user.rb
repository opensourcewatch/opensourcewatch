class User < ActiveRecord::Base
  validates :github_username, uniqueness: true
  
  has_many :commits
end

class User < ActiveRecord::Base
  validates :github_username, uniqueness: true
end
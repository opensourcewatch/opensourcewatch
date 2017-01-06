class Repository < ActiveRecord::Base
  validates :github_id, uniqueness: true
end

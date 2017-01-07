class Repository < ActiveRecord::Base
  validates :github_id, uniqueness: true

  has_many :commits
end

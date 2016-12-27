class Commit < ActiveRecord::Base
  validates :github_identifier, uniqueness: true

  belongs_to :user
end
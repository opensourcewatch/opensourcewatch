class Issue < ActiveRecord::Base
  belongs_to :repository

  has_many :issue_comments

  validates :issue_number, uniqueness: { scope: [self.repository.id] }
end

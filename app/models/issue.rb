class Issue < ActiveRecord::Base
  belongs_to :repository

  has_many :issue_comments
end

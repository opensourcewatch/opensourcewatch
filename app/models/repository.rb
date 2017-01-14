# TODO: There eventually needs to be a callback here to add a Repository to the
#       Redis queue on creation
class Repository < ActiveRecord::Base
  include Comparable

  validates :github_id, uniqueness: true, on: :create
  attr_protected :github_id, as: :update

  has_many :commits
  has_many :issues

  def update_score
    update(score: calculate_score)
  end

  def calculate_score
    activity_score + significance_score
  end

  def <=>(other)
    score <=> other.score
  end

  private

  def activity_score
    # TODO: We should only get the commits for a given time period, when calculating
    # this, not all the commits on a repository.Should we add scoring for issues
    # based on comments activity?
    commits.count + open_issues.to_i
  end

  def significance_score
    # convert any nil values to zero with to_i
    stars.to_i + forks.to_i + watchers.to_i
  end
end

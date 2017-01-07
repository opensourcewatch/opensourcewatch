class Repository < ActiveRecord::Base
  validates :github_id, uniqueness: true

  has_many :commits

  def update_score
    update(score: score)
  end

  def score
    activity_score + significance_score
  end

  private

  def activity_score
    # TODO: we should only get the commits for a given time period, not all the commits on a repository
    # TODO: Add migration and scraping for issues to the commit path as an option, then uncomment below
    commits.count #+ open_issues.to_i
  end

  def significance_score
    # to_i is to convert nil values to zero
    stars.to_i + forks.to_i + watchers.to_i
  end
end

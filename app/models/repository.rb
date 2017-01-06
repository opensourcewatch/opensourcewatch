class Repository < ActiveRecord::Base
  validates :github_id, uniqueness: true

  has_many :commits

  # NOTE: Saved for later--when we begin scraping repos
  # def self.update_score
  #   avg_downloads = self.average(:downloads).to_i
  #   avg_stars = self.average(:stars).to_i
  #
  #   # TODO: Make equation more mathematically correct (make it better)
  #   star_multiplier = (avg_downloads / (avg_stars + 1)) + 200
  #
  #   self.all.each do |gem|
  #     score = gem.downloads + gem.stars * star_multiplier
  #     gem.update(score: score)
  #   end
  # end

end

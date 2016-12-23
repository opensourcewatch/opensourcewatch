require_relative "./scraper/github_scraper"
require_relative "./scraper/ruby_gems_scraper"

RubyGemsScraper.upsert_gems
GithubScraper.update_gem_data
RubyGem.update_score

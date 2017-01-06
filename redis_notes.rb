gem 'redis'

require 'redis'

# New Redis connection
# Assumes default configuration of localhost:6379
redis = Redis.new

Redis.new(
  :connect_timeout => 0.2,
  :read_timeout    => 1.0,
  :write_timeout   => 0.5
)


# The circular queue
#         -------------
#        |            |
#       |            V
# list: 0 1 2 3 4 5 x
#
# rpush creates the list if it doesn't exist
redis.rpush('rubygems', 'url')
redis.rpush('rubygems', '0:99')
redis.rpush('rubygems', 'ccgem:3')
# => 'aagem', 'bbgem', 'ccgem'

# To get first item in queue
scraper.current_gem = redis.lpop('rubygems')
# => 'aagem'

# after the scraper is finished...
redis.rpush('rubygems', scraper.current_gem)
redis.lrange('rubygems', 0, -1)
# => 'bbgem', 'ccgem', 'aagem'


RubyGemScraper.scraping...
- stores in postgresql
  - on save: redis.rpush('rubygems', current_gem.name ':' gem.id)

GithubScraper

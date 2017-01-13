# Requires a redis connection to a valid redis server.
class RedisWrapper

  attr_reader :redis

  def initialize
    redis
  end

  def queue_length(queue_name)
    redis.llen(queue_name).to_i
  end

  def redis
    ip = ENV['REDIS_SERVER_IP']
    pw = ENV['REDIS_SERVER_PW']

    @redis ||= Redis.new(
      host: ip,
      password: pw
    )
  end
end

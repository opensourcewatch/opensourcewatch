namespace :redis do
  task :priority_requeue, [:queue_name, :query] => :environment do |t, args|
    puts "Enqueuing priority queue..."
    RedisWrapper.new.redis_priority_requeue(args.to_h)
  end

  task :requeue, [:queue_name, :query] => :environment do |t, args|
    puts "Enqueuing redis..."
    RedisWrapper.new.redis_requeue(args.to_h)
  end
end

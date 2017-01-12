namespace :redis do
  task :priority_requeue do

  end
  
  task :requeue, [:queue_name, :query] => :environment do |t, args|
    puts "Enqueuing redis..."
    ScraperDispatcher.redis_requeue(args.to_h)
  end
end

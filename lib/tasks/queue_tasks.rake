namespace :dispatcher do
  task :all => :environment do
    Dispatcher.enqueue_all
    Dispatcher.circular_queue
  end
end

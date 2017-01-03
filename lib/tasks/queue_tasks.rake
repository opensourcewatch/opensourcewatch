namespace :dispatcher do
  require_relative '../dispatcher/dispatcher'
  task :all => :environment do
    Dispatcher.enqueue_all
    Dispatcher.circular_queue
  end
end

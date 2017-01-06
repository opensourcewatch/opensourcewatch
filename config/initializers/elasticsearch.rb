# TODO: code is not currently in use...
Elasticsearch::Model.client =
  if Rails.env.staging? || Rails.env.production?
    Elasticsearch::Client.new url: ENV['SEARCHBOX_URL']
  elsif Rails.env.development?
    Elasticsearch::Client.new log: true
  else
    Elasticsearch::Client.new
  end

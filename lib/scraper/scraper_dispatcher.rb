class ScraperDispatcher
  def self.scrape_commits
    # TODO: set url to env variable = heroku host
    conn = Faraday.new(url: 'http://4f4f870d.ngrok.io')
    loop do
      response = conn.get '/next_job'
      puts JSON.parse(response.body)
      gem_id = JSON.parse(response.body)['gem_id']
      GithubScraper.lib_commits(libraries: [ RubyGem.find(gem_id) ])
    end
  end
end

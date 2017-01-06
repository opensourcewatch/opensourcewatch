def query(query_param = 'stars:>1')
  @query = "?q=''&q=#{query_param}&sort=stars&order=desc"
end

@base_url = 'https://api.github.com'
@search_path = '/search/repositories'
@curr_url = @base_url + @search_path + query

@access_token = ENV["GITHUB_API_KEY"]

def upsert_lib(repo)
  puts "Upserting Repository."
  attrs = {
    name: repo['name'],
    github_id: repo['id'],
    url: repo['html_url'],
    language: repo['language'],
    stars: repo['stargazers_count'],
    forks: repo['forks']
  }

  if Repository.exists?(github_id: repo['id'])
    Repository.update(attrs)
  else
    Repository.create(attrs)
  end
  puts "Repository Upserted"
end

def last_pagination?
  !@resp.headers['link'].include?('rel="last"')
end

def paginate
  loop do
    loop do
      @resp = search_request
      puts "Search request to #{@curr_url}"

      rate_requests_remain? ? handle_request : break
    end
    puts "Out of requests... Sleeping"
    puts "Beginning at #{time_to_reset}"

    wait = Time.at(time_to_reset) - Time.now
    sleep wait unless wait.negative?
  end
end

def handle_request
    parse_repos

    if last_pagination?
      last_stars = Repository.last.stars
      @curr_url = @base_url + @search_path + query("stars:<=#{last_stars}")
    else
      @curr_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
    end
end

def parse_repos
  JSON.parse(@resp.body)['items'].each do |repo_hash|
    upsert_lib(repo_hash)
  end
end

def search_request
  Faraday.get(@curr_url) do |req|
      req.headers['Authorization'] = "token #{@access_token}"
      req.headers['Accept'] = 'application/vnd.github.v3+json'
  end
end

def rate_requests_remain?
  requests_remaining > 0
end

def requests_remaining
  @resp.headers['x-ratelimit-remaining'].to_i
end

def time_to_reset
  @resp.headers['x-ratelimit-reset'].to_i
end

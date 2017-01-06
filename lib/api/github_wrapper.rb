require 'faraday'
require 'pry'
require 'json'

def query(query_param = 'stars:>1')
  @query = "?q=''&q=#{query_param}&sort=stars&order=desc"
end

@base_url = 'https://api.github.com'
@search_path = '/search/repositories'
@curr_url = @base_url + @search_path + query

@access_token = ENV["GITHUB_API_KEY"]

@repo_struct = Struct.new(:name,
                          :github_project_id,
                          :github_owner_id,
                          :github_owner_name, # not necessarily a user
                          :github_owner_url,
                          :url,
                          :language,
                          :stars,
                          :forks)

def hash_to_struct(repo)
  @repo_struct.new(repo['name'],
                   repo['id'],
                   repo['owner']['id'],
                   repo['owner']['login'],
                   repo['owner']['html_url'],
                   repo['html_url'],
                   repo['language'],
                   repo['stargazers_count'],
                   repo['forks'])
end

def last_pagination?
  !@resp.headers['link'].include?('rel="last"')
end

def paginate
  @repos = []

  loop do
    @resp = Faraday.get(@curr_url) do |req|
        req.headers['Authorization'] = "token #{@access_token}"
        req.headers['Accept'] = 'application/vnd.github.v3+json'
    end

    if rate_requests_remaining
      repos_as_hashes = JSON.parse(@resp.body)['items']
      repos_as_hashes.each do |repo_hash|
        @repos << hash_to_struct(repo_hash)
      end

      if last_pagination?
        last_stars = @repos.last[:stars]
        @curr_url = @base_url + @search_path + query("stars:<=#{last_stars}")
        binding.pry
      else
        @curr_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      end
    end

  end
end

def rate_requests_remaining
  @resp.headers['x-ratelimit-remaining'].to_i > 0
end

paginate

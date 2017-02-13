source 'https://rubygems.org'
ruby "2.3.0"

gem 'nokogiri'  # Scraping
gem 'httplog'   # Log requests

# Assets
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Compressor for JavaScript assets
gem 'jquery-rails' # JavaScript library
gem 'rouge'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Infrastructure
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'puma', '~> 3.0' # App server
gem "pg" # Use PostGreSQL
gem 'redis'
gem 'figaro'
gem 'activerecord-import'
gem 'json'
gem 'whenever', require: false
gem 'font-awesome-rails'

# JS Runtime
gem 'therubyracer'

# Better search
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# Material design
gem 'materialize-sass'

group :development, :test do
  gem 'pry'     # Debugging
  gem 'pry-nav' # Navigate while in pry console

  # Fabricate data
  gem 'fabrication'
  gem 'faker'

  # Testing
  gem 'rspec-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

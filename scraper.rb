require 'nokogiri'
require 'open-uri'

def scrape_gem_meta_data(gems, base_url, doc)
  # scrape per page of results
  doc.css('a.gems__gem').each do |gem_link|
    gem_url = base_url + gem_link['href'] # /gems/gem_name
    gem_doc = Nokogiri::HTML(open(gem_url))

    gem_name = gem_doc.css('h1 a')[0].text.strip
    gem_downloads = gem_doc.css('.gem__downloads')[0].text.strip
    github_url = ''
    home = gem_doc.css('#home')
    source = gem_doc.css('#code')

    if home.any? && home[0]['href'].include?('github')
      github_url = home[0]['href']
    elsif source.any? && source[0]['href'].include?('github')
      github_url = source[0]['href']
    end

    if github_url.length > 0
      unless RubyGem.exists?(name: gem_name)
        gem = RubyGem.create(name: gem_name, url: github_url, downloads: gem_downloads)
      end
    end
  end
end

# Gets the following:
# - raw README.md file 
# - number of stars the project has
#
# Example project's Github url vs raw url
# - Github: https://github.com/rspec/rspec/blob/master/README.md
# - Raw: https://raw.githubusercontent.com/rspec/rspec/master/README.md
def scrape_gem_github_data
  ex_github_url = 'https://github.com/rails/rails'
  github_doc = Nokogiri::HTML(open(ex_github_url))
  
  RubyGem.all.each do |gem|
    github_doc = Nokogiri::HTML(open(gem.url))
    stars = github_doc.css('ul.pagehead-actions li:nth-child(2) .social-count').to_s[/\d+\,\d+/]

    raw_url = ex_github_url.gsub('github', 'raw.githubusercontent') + '/master/README.md'
    description = Nokogiri::HTML(open(raw_url)).css('body p').text

    gem.update(stars: stars, description: description)
  end
end

def update_score
  avg_downloads = RubyGem.average(:downloads)
  avg_stars = RubyGem.average(:stars)
  star_multiplier = (avg_downloads / avg_stars) + 200

  RubyGem.all.each do |gem|
    score = gem.downloads + gem.stars * star_multiplier
    gem.update(score: score)
  end
end

base_url = 'https://rubygems.org'

alphabet = ('A'..'Z').to_a

category_url = "/gems?letter="
alphabet.each do |letter|
  page_num = 1
  loop do
    doc = Nokogiri::HTML(open(base_url + category_url + letter + "&page=#{page_num}"))
    scrape_gem_meta_data(gems, base_url, doc)

    page_num += 1
    break if doc.css('.next_page .disabled').any?
  end
end

scrape_gem_github_data
update_score
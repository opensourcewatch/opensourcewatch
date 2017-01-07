require_relative './noko_doc'

# TODO: test taht still functions after being extracted
class GithubUserScraper
  @github_doc = NokoDoc.new

  # 2 agents for user data and stars/followers data
  def update_user_data
    User.all.each do |user|
      break unless @github_doc.new_doc("https://github.com/#{user.github_username}")
      followers = @github_doc.doc.css('a[href="/#{user.github_username}?tab=followers .counter"]').text.strip
      name = @github_doc.doc.css('.vcard-fullname').text.strip

      personal_repos_doc = NokoDoc.new_temp_doc("https://github.com/#{user.github_username}?page=1&tab=repositories")
      break unless personal_repos_doc
      personal_star_count = 0
      pagination_count = 1

      loop do
        personal_repos_doc.css('a[aria-label="Stargazers"]').each do |star_count|
          personal_star_count += star_count.text.strip.to_i
        end

        break if personal_repos_doc.css('.next_page.disabled').any?

        pagination_count += 1
        page_regex = /page=#{pagination_count}/

        personal_repos_doc = NokoDoc.new_temp_doc("https://github.com/#{user.github_username}?page=1&tab=repositories".gsub(/page=\d/, "page=#{pagination_count}"))
        break unless personal_repos_doc
      end

      User.update(user.id,
                  name: name,
                  followers: followers,
                  stars: personal_star_count)
    end
  end
end

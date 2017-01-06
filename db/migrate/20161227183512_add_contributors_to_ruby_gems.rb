class AddContributorsToRubyGems < ActiveRecord::Migration[5.0]
  def change
    add_column :ruby_gems, :contributors, :integer
  end
end

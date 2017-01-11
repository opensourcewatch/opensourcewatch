class DropRubyGems < ActiveRecord::Migration[5.0]
  def change
    drop_table :ruby_gems
  end
end

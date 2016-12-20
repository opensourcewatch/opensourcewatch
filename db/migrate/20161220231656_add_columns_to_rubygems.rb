class AddColumnsToRubygems < ActiveRecord::Migration[5.0]
  def change
    add_column :ruby_gems, :stars, :integer
    add_column :ruby_gems, :score, :float
    add_column :ruby_gems, :description, :text
  end
end

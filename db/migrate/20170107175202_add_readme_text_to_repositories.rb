class AddReadmeTextToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :readme_content, :text
  end
end

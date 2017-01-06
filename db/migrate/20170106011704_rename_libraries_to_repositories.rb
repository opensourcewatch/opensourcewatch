class RenameLibrariesToRepositories < ActiveRecord::Migration[5.0]
  def change
    rename_table :libraries, :repositories
  end
end

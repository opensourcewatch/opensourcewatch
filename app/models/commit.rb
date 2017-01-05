class Commit < ActiveRecord::Base
  validates :github_identifier, uniqueness: true

  belongs_to :user
  belongs_to :ruby_gem

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |commit|
        csv << commit.attributes.values_at(*column_names)
      end
    end
  end
end

class Matviews::Matview < ActiveRecord::Base

  def self.refresh
    puts "Attempting to refresh: #{self.table_name}"
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.table_name}")
    puts "#{self.table_name} refreshed"
  end

  def readonly?
    true
  end

end

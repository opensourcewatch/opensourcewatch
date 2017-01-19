class RepoActivityMatviewLast90 < ActiveRecord::Base
  self.table_name = "repo_activity_matview_last_90"

  def self.refresh
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW repo_activity_matview_last_90')
  end

  def readonly?
    true
  end
end

class Matviews::RepoActivityLast0 < ActiveRecord::Base
  self.table_name = "repo_activity_matview_last_0"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::RepoActivityLast7 < ActiveRecord::Base
  self.table_name = "repo_activity_matview_last_7"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::RepoActivityLast30 < ActiveRecord::Base
  self.table_name = "repo_activity_matview_last_30"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end


class Matviews::RepoActivityLast90 < ActiveRecord::Base
  self.table_name = "repo_activity_matview_last_90"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW  #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

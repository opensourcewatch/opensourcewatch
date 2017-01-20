
class Matviews::IssueActivityLast0 < ActiveRecord::Base
  self.table_name = "issue_activity_matview_last_0"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::IssueActivityLast7 < ActiveRecord::Base
  self.table_name = "issue_activity_matview_last_7"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::IssueActivityLast30 < ActiveRecord::Base
  self.table_name = "issue_activity_matview_last_30"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end


class Matviews::IssueActivityLast90 < ActiveRecord::Base
  self.table_name = "issue_activity_matview_last_90"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW  #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

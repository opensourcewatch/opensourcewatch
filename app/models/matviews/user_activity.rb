
class Matviews::TopUserLast0 < ActiveRecord::Base
  self.table_name = "top_user_matview_last_0"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::TopUserLast7 < ActiveRecord::Base
  self.table_name = "top_user_matview_last_7"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::TopUserLast30 < ActiveRecord::Base
  self.table_name = "top_user_matview_last_30"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end


class Matviews::TopUserLast90 < ActiveRecord::Base
  self.table_name = "top_user_matview_last_90"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW  #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::ChattiestUserLast0 < ActiveRecord::Base
  self.table_name = "top_user_matview_last_0"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::ChattiestUserLast7 < ActiveRecord::Base
  self.table_name = "chattiest_user_matview_last_7"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

class Matviews::ChattiestUserLast30 < ActiveRecord::Base
  self.table_name = "chattiest_user_matview_last_30"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{self.class.table_name}")
  end

  def readonly?
    true
  end
end


class Matviews::ChattiestUserLast90 < ActiveRecord::Base
  self.table_name = "chattiest_user_matview_last_90"

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW  #{self.class.table_name}")
  end

  def readonly?
    true
  end
end

module Matviews::RepoActivity
  class Last0 < Matviews::Matview
    self.table_name = "repo_activity_matview_last_0"
  end

  class Last7 < Matviews::Matview
    self.table_name = "repo_activity_matview_last_7"
  end

  class Last30 < Matviews::Matview
    self.table_name = "repo_activity_matview_last_30"
  end

  class Last90 < Matviews::Matview
    self.table_name = "repo_activity_matview_last_90"
  end
end

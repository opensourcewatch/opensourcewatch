class LandingController < ApplicationController
  def index
    Rails.application.eager_load!
    @repos = Matviews::RepoActivityLast0.limit(10)
    @committers = Matviews::TopUserLast0.limit(10)
    @issues = Matviews::IssueActivityLast0.limit(10)
    @chatty = Matviews::ChattiestUserLast0.limit(10)
  end
end

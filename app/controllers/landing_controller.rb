class LandingController < ApplicationController
  def index
    Rails.application.eager_load!
    set_activity_vars
  end

  private

  def date_range_postfix
    case params['date_range']
    when 'Today'
      'Last0'
    when 'Weekly'
      'Last7'
    when 'Monthly'
      'Last30'
    when 'Last 90'
      'Last90'
    else
      'Last0'
    end
  end

  def set_activity_vars
    postfix = date_range_postfix
    @repos = Module.const_get("Matviews::RepoActivity#{postfix}").limit(10)
    @committers = Module.const_get("Matviews::TopUser#{postfix}").limit(10)
    @issues = Module.const_get("Matviews::IssueActivity#{postfix}").limit(10)
    @chatty = Module.const_get("Matviews::ChattiestUser#{postfix}").limit(10)
  end
end

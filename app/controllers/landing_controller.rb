class LandingController < ApplicationController
  before_action :set_activity_vars

  def index
    respond_to do |type|
      type.html
      type.js do
        render partial: 'landing/index.js.erb'
      end
    end
  end

  def about

  end

  private

  def set_activity_vars
    postfix = date_range_postfix
    @repos = Module.const_get("Matviews::RepoActivity::#{postfix}").limit(10)
    @committers = Module.const_get("Matviews::TopUser::#{postfix}").limit(10)
    @issues = Module.const_get("Matviews::IssueActivity::#{postfix}").limit(10)
    @chatties = Module.const_get("Matviews::ChattiestUser::#{postfix}").limit(10)
  end

  def date_range_postfix
    case params['date_range']
    when 'today'
      'Last0'
    when 'weekly'
      'Last7'
    when 'monthly'
      'Last30'
    when 'last 90'
      'Last90'
    else
      'Last0'
    end
  end
end

class RubyGemsController < ApplicationController
  def index
    @gems = RubyGem.order(downloads: :desc)
  end

  def search
    term = params[:search]
    if term != ""
      @gems = RubyGem.search(term).records.to_a
      binding.pry
      render :index
    else
      flash[:error] = "If you don't know how to search... should you be looking?"
      redirect_to ruby_gems_path
    end
  end
end

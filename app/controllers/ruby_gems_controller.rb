class RubyGemsController < ApplicationController
  def index
    @gems = RubyGem.order(score: :desc)
  end

  def search
    term = params[:search]
    if term != ""
      search = RubyGem.search(term)

      results = search.results
      gems = search.records.to_a

      @search_results = []
      gems.each_with_index do |gem, idx|
        highlight = results[idx].highlight
        if highlight.description
          description = highlight.description[0]
        else
          description = gem.description
        end

        if highlight.name
          name = highlight.name[0]
        else
          name = gem.name
        end

        @search_results << {
          "description": description,
          "name": name
        }
      end

      render :index
    else
      flash[:error] = "If you don't know how to search... should you be looking?"
      redirect_to ruby_gems_path
    end
  end
end

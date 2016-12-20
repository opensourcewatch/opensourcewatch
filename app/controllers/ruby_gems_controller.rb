class RubyGemsController < ApplicationController
  def index
    @gems = RubyGem.all
  end
end

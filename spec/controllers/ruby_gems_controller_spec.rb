require 'rails_helper'

describe RubyGemsController do
  describe "GET index" do
    before do
      Fabricate(:ruby_gem)
      Fabricate(:ruby_gem)

      get :index
    end

    it "returns successfully" do
      expect(response).to be_successful
    end
  end
end

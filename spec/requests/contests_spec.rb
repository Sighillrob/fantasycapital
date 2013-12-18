require 'spec_helper'

describe "Contests," do
  describe "Contests" do
    it "GET /contests/index" do
      get "/contest/index"
      response.status.should be(200)
    end
  end
end

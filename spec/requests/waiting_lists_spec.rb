require 'spec_helper'

describe "WaitingLists" do
  describe "GET /waiting_lists" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get waiting_lists_path
      response.status.should be(200)
    end
  end
end

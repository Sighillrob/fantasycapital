require 'spec_helper'

describe EntriesController do

  before :each do
    @contest = FactoryGirl.create(:contest)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', contest_id: @contest.id
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

end

require 'spec_helper'

describe EntriesController do

  before :each do
    @contest = FactoryGirl.create(:contest)
    @player = FactoryGirl.create(:player)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', contest_id: @contest.id
      response.should be_success
    end
  end

#  describe "GET 'edit'" do
#    it "returns http success" do
#      get 'edit'
#      response.should be_success
#    end
#  end
#
#  describe "GET 'show'" do
#    it "returns http success" do
#      get 'show'
#      response.should be_success
#    end
#  end
#
  describe "POST 'create'" do
    describe "with valid params" do
      it "creates a new Entry" do
        expect {
          post :create, {contest_id: @contest.id, player_ids: [@player.id]}
        }.to change(Entry, :count).by(1)
      end
    end
  end
end

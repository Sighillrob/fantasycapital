require 'spec_helper'

describe EntriesController do
  let!(:contest) { create(:contest)}
  let(:user) { create(:user) }

  before :each do
    @player = FactoryGirl.create(:player)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in :user, user
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', contest_id: contest.id

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
#  describe "POST 'create'" do
#    describe "with valid params" do
#      it "creates a new Entry" do
#        expect {
#          post :create, {contest_id: @contest.id, entry: {player_ids: [@player.id]}}
#        }.to change(Entry, :count).by(1)
#      end
#    end
#  end
end

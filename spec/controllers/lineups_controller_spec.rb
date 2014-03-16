require 'spec_helper'

describe LineupsController do
  let!(:contest) { create(:contest, max_entries: 2)}
  let(:user) { create(:user) }
  let(:sport_pos) { create(:sport_position) }

  before :each do
    @player = create(:player)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in :user, user
  end

  describe "when contest has no entires" do
    it "should succeed when user enters the contest" do
      expect {
        post :create, {lineup: {contest_id_to_enter: contest.id, sport: "NBA"}}
      }.to change(Entry, :count).by(1)
    end
  end

  describe "when contest is filled" do
    before :each do
      contest.entries.create(lineup: create(:lineup))
      contest.entries.create(lineup: create(:lineup))
    end

    it "should redirect to / when user tries to enter" do
      post :create, {lineup: {contest_id_to_enter: contest.id, sport: "NBA"}}
      response.should redirect_to "/"
    end
  end

end

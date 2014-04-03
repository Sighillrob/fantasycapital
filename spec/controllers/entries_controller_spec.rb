require 'spec_helper'

describe EntriesController do
  #let!(:contest) { create(:contest)}
  #let(:user) { create(:user) }
  #let(:player) { create(:player)}

  let!(:positions) { create_list(:sport_position, 6)}
  let(:user) { create(:user) }
  let!(:lineup) { create(:lineup, user:user)}
  let!(:teams) { create_list(:team, 4)}
  let!(:players) { (0..12).map { |i| create(:player, sport_position: positions[i % 6],
                                             team: teams[i%2]) } }
  let!(:lineupspots) { (0..9).map { |i| create(:lineup_spot, player: players[9-i], spot:9-i,
                                               sport_position:players[9-i].sport_position,
                                               lineup:lineup) } }

  # one day's entries and contest, with 2 games. No player from this entry is in game2
  let!(:contest) { create(:contest, contestdate:"2014-03-21")}
  let!(:entry) { create(:entry, contest:contest, lineup:lineup) }
  let!(:entry2) { create(:entry, contest:contest, lineup:lineup) }

  let!(:game) {create(:game_score, playdate:"2014-03-21", home_team: teams[0], away_team: teams[1])}
  let!(:game2) {create(:game_score, playdate:"2014-03-21", home_team: teams[2], away_team: teams[3])}
  let!(:playercontests) { (0..9).map { |i| create(:player_contest, player: players[9-i],
                                                   contest: contest)} }

  # another day's entry and contest (with no game)
  let!(:game_day2) {create(:game_score, playdate:"2014-03-22", home_team: teams[2],
                            away_team: teams[3])}

  let!(:contest_day2) { create(:contest, contestdate:"2014-03-22")}
  let!(:entry_day2) { create(:entry, contest:contest_day2, lineup:lineup) }

  # every player playing in a game will have an "fp" score previously set during contest creation
  let!(:rtscores) { (0..9).map { |i| create(:player_real_time_score, player:players[i],
                                             game_score:game, name: "fp", value:i*2) } }

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in :user, user
  end

  describe "GET 'show'" do
    it "correctly assigns players and entries with fantasypoints" do
      get 'show', id: entry.id
      # FYI, assigns(:blah) returns value of instance variable @blah in the controller
      expect(response.status).to eq(200)
      retplayers = assigns(:players)
      expect(assigns(:todaysgames)).to eq([game, game2])
      expect(retplayers.count).to be(10)
      expect(retplayers[5]['currfps']).to eq(10)
      expect(retplayers[6]['currfps']).to eq(12)
      expect(assigns(:entries).to_a).to eq([entry, entry2])
    end
  end

  describe "GET 'new'" do
    #it "returns http success" do
     # get 'new', contest_id: contest.id

     # response.should be_success
    #end
  end


#  describe "GET 'edit'" do
#    it "returns http success" do
#      get 'edit'
#      response.should be_success
#    end
#  end
#
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

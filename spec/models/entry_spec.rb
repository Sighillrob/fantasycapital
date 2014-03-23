# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  lineup_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  contest_id :integer
#

require 'spec_helper'

describe Entry do
  let!(:positions) { create_list(:sport_position, 6)}
  let(:user) { create(:user) }
  let!(:lineup) { create(:lineup, user:user)}
  let!(:teams) { create_list(:team, 4)}
  let!(:players) { (0..9).map { |i| create(:player, sport_position: positions[i % 6], team: teams[i%2]) } }
  let!(:lineupspots) { (0..9).map { |i| create(:lineup_spot, player: players[9-i], spot:9-i,
                                               sport_position:players[9-i].sport_position,
                                               lineup:lineup) } }

  # one day's entry and contest, with 2 games. No player from this entry is in game2
  let!(:contest) { create(:contest, contestdate:"2014-03-21")}
  let!(:entry) { create(:entry, contest:contest, lineup:lineup) }
  let!(:game) {create(:game_score, playdate:"2014-03-21", home_team: teams[0], away_team: teams[1])}
  let!(:game2) {create(:game_score, playdate:"2014-03-21", home_team: teams[2], away_team: teams[3])}

  # another day's entry and contest (with no game)
  let!(:contest_day2) { create(:contest, contestdate:"2014-03-22")}
  let!(:entry_day2) { create(:entry, contest:contest_day2, lineup:lineup) }
  #let!(:game_day2) {create(:game_score, playdate:"2014-03-22", home_team: teams[0], away_team: teams[1])}

  it { should belong_to(:lineup) }

  it "reports players according to their positional order when JSONified" do
    # this is what's sent to browser during gametime. need to ensure sort order.
    entry_parsed = JSON.parse(entry.to_json)

    # make sure players are reported in order of their 'spot' index, so that spots go from 0-9.
    entry_parsed['player_ids'].each_with_index { |(playerid, sport_pos_id), idx|
      expect(lineupspots[9-idx].player.id).to be(playerid)
      expect(lineupspots[9-idx].sport_position.id).to be(sport_pos_id)
      puts "#{playerid}  #{sport_pos_id}"
    }
  end

  it "reports what games it belongs to" do
    entry_games = entry.games
    expect(entry_games.count).to be(1)
    expect(entry_games.first).to eq(game)
  end

  it "reports no games if it's empty" do
    entry_games = entry_day2.games
    expect(entry_games.count).to be(0)
  end

end

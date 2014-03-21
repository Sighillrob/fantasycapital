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

  let!(:contest) { create(:contest)}
  let(:user) { create(:user) }
  let!(:lineup) { create(:lineup, user:user)}
  let!(:entry) { create(:entry, contest:contest, lineup:lineup) }
  let!(:players) { (0..9).map { |i| create(:player, sport_position: positions[i % 6]) } }
  let!(:lineupspots) { (0..9).map { |i| create(:lineup_spot, player: players[9-i], spot:9-i,
                                                sport_position:players[9-i].sport_position,
                                                lineup:lineup) } }

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

end

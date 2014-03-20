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
  let!(:lineupspots) { (0..9).map { |i| create(:lineup_spot, player: players[9-i],
                                                sport_position:players[9-i].sport_position,
                                                lineup:lineup) } }

  it { should belong_to(:lineup) }

  it "reports players according to their positional order when JSONified" do
    # this is what's sent to browser during gametime. need to ensure sort order.
    entry_parsed = JSON.parse(entry.to_json)

    # display priority of the position of each player should be monotonically increasing, otherwise
    # they will display in browser in wrong order.
    disp_priorities = entry_parsed['player_ids'].map { |playerid|
      Player.find(playerid).sport_position.display_priority
    }
    (0..8).each { |i|
      expect(disp_priorities[i]).to be <= disp_priorities[i+1]
    }
    puts "HI"
  end

end

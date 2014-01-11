require 'spec_helper'

describe Projection::FantasyPointCalculator do
  let(:player) do
    p = create(:projection_player)
    create(:projection_stat, stat_name: "Points", stat_value: 10)
    create(:projection_stat, stat_name: "Rebounds", stat_value: 8)
  end

  subject { Projection::FantasyPointCalculator.new(player) }

  describe "only 1 game exists" do
#    its(:latest_points) { should == 10 + 8*1.25 }

    context "all NBA stats are in" do
      before(:each) do
        create(:projection_stat, stat_name: "Assists", stat_value: 3)
        create(:projection_stat, stat_name: "Steals", stat_value: 5)
        create(:projection_stat, stat_name: "Blocks", stat_value: 6)
        create(:projection_stat, stat_name: "Turnovers", stat_value: 7)
      end

#      its(:latest_points) { should == 10 + 8*1.25 + 3 * 1.5 + 5 * 2 + 6 * 2 + 7 * -1 }
    end
  end

end

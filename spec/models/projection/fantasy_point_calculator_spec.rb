require 'spec_helper'

describe Projection::FantasyPointCalculator do

  subject { Projection::FantasyPointCalculator.new }

  describe "only 1 game exists" do

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

require 'spec_helper'

describe Contest do

  subject {Contest.all}

  let!(:teams) do [
      create(:team),
      create(:team),
      create(:team)
  ]
  end
  let!(:games) do
    [
        # create games that are in the future so the contests get created.
        create(:game_score, playdate: "2018-01-16"),
        create(:game_score, playdate: "2018-01-16"),
        create(:game_score, playdate: "2018-01-16"),
        create(:game_score, playdate: "2018-01-17"),
        create(:game_score, playdate: "2018-01-17"),
        create(:game_score, playdate: "2018-01-17"),
        create(:game_score, playdate: "2018-01-18")
    ]
  end


  before do
    ContestFactory.create_nba_contests
  end

  describe "when 7 games are scheduled over 3 days" do

    it {
      should have(54).items   # 27 contests for each game day, 2 game days with >= 3 contests
    }
    it {
      subject.first.contest_start.should == games[0].scheduledstart
    }

    it "should be idemopotent (identical results when called more than once)" do
      count = subject.count
      ContestFactory.create_nba_contests
      subject.count.should == count
    end
  end

  ## NB: I don't understand this test. Ask Kenneth...
  #
  #describe "when 2 games are scheduled for the day" do
  #
  #  let(:games) do
  #    [
  #    create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00"),
  #    create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00")
  #    ]
  #  end
  #
  #  it {
  #    should have(0).items
  #  }
  #
  #end
end

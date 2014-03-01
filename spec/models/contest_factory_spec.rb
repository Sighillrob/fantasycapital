require 'spec_helper'

describe Contest do

  subject {Contest.all}

  before do
    allow(Projection::ScheduledGame).to receive(:games_on).and_return (games) 
    ContestFactory.create_nba_contests
  end

  describe "when 3 games are scheduled for the day" do

    let(:games) do
      [
      create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00"),
      create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00"),
      create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00")
      ]
    end

    it { should have_at_least(1).items }

    it { subject.first.contest_start.should == games[0].start_date }
  end

  describe "when 2 games are scheduled for the day" do

    let(:games) do
      [
      create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00"),
      create(:projection_scheduled_game, start_date: "2014-01-16 19:30:00-05:00")
      ]
    end

    it { should have(0).items }

  end
end

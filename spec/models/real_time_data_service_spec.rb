require 'spec_helper'

describe RealTimeDataService do
  before { Player.create(ext_player_id: "a") }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:game_summary) do
    { 'id' => "aaa-id-of-game-1",
        'home' => {},
        'away' => {},
        'home_team' => "xxx-id-of-team-1",
        'away_team' => "yyy-id-of-team-2",
        'status' => 'inprogress',
        'scheduled' => DateTime.now
      }
  end
  let (:game_details) do
    { 'period' => "2",
      'clock' => "4:25",
      'team' => [{'points' => "54",
                  'players' => { 'player'=> [
                      { "id" => "a",
                        "statistics" => {"assists" => "1.0", "steals" => "2", "rebounds" => "3" }
                      }
                  ]
                  }
                 },
                 {'points' => "22",
                  'players' => { 'player'=> [
                      { "id" => "4",
                        "statistics" => {"assists" => "3.0", "steals" => "4", "rebounds" => "5" }
                      }
                  ]
                  }
                 }],
    }
  end

  context "the first time it's called" do
    before do
      pusher_mock = double('channel') # rspec object that stands in for another object
      Pusher.stub(:[]).with('gamecenter').and_return(pusher_mock)
      @contest = FactoryGirl.create(:contest, contest_start: Time.now - 60)

      @lineup = create(:lineup, user: user)
      @lineup2 = create(:lineup, user: user2)

      @entry = create(:entry, contest: @contest, lineup: @lineup)
      @entry = create(:entry, contest: @contest, lineup: @lineup2)

      # will get a game update, a players update, and an entry update message
      pusher_mock.should_receive(:trigger).exactly(3).times do |event, msg|
         event.should == 'stats'
         @games = msg['games'] unless !msg['games']
         @message = msg['players'] unless !msg['players']
         @entries = msg['entries'] unless !msg['entries']
      end
      RealTimeDataService.new.refresh_game(game_summary, game_details)
    end

    it { PlayerRealTimeScore.all.should have(4).items }
    it { @message.should have(4).items }
    it "should includes fp" do
      stats = @message.select {|s| s["stat_name"] == "fp"}
      stats.should have(1).items
      stats[0]["stat_value"].should == 9.25
    end
    it "will have an entry" do
      expect(@entries).to be_true
      expect(@entries.length).to eq(2)
      expect(@entries[0]['id']).to be > 0
    end
  end

  context "called again with no change" do
    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger).exactly(3).times

      RealTimeDataService.new.refresh_game(game_summary, game_details)
      RealTimeDataService.new.refresh_game(game_summary, game_details)
    end

    it { PlayerRealTimeScore.all.should have(4).items }
  end

  context "called again with changes in scores" do

    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # receive 3 times for initial refresh, then 3 times for second refresh
      mock_channel.should_receive(:trigger).exactly(3).times.ordered
      mock_channel.should_receive(:trigger).exactly(3).times.ordered do |event, msg|
         @message = msg['players'] unless !msg['players']
      end
      RealTimeDataService.new.refresh_game(game_summary, game_details)
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'][0]['statistics']['steals'] = 82
      RealTimeDataService.new.refresh_game(game_summary, game_src1)
    end

    it { @message.should have(2).items }
    it "should includes fp" do
      stats = @message.select {|s| s["stat_name"] == "fp"}
      stats.should have(1).items
      stats[0]["stat_value"].should == 169.25   # updated by large # of steals
    end
  end

  context "when there are many stats to message" do

    it "should not exceed 50 stats/msg" do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # with 100 changes in pipe, we should get 2 message batches. Each message batch has 4
      # Pusher msgs in it, so in total 8 Pusher messages.
      mock_channel.should_receive(:trigger).exactly(8).times do |event, msg|
         msg['players'].count.should <= 50 unless !msg['players']
      end
      game_src1 = game_details.clone
      100.times do
        game_src1['team'][0]['players']['player'] <<
            { "id" => "a",
               "statistics" => {"assists" => rand(20).to_s, "steals" => rand(10).to_s,
                                "rebounds" => "3" }
             }
      end
      RealTimeDataService.new.refresh_game(game_summary, game_src1)
    end

  end

  context "when a contest ends" do
    it 'will receive a contest object over realtimedataservice' do
      pending "need to add this"
    end
  end

  context "when a contest starts" do
    it 'will receive a contest object over realtimedataservice' do
      pending "need to add this"
    end
  end
end


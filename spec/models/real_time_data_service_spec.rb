require 'spec_helper'

describe RealTimeDataService do
  before { Player.create(ext_player_id: "a") }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:game_schedule) do
    [{ 'id' => "aaa-id-of-game-1",
        'home' => {},
        'away' => {},
        'home_team' => "xxx-id-of-team-1",
        'away_team' => "yyy-id-of-team-2",
        'status' => 'inprogress',
        'scheduled' => DateTime.now,
        "home"=>
          {"name"=>"Philadelphia 76ers",
               "alias"=>"PHI",
                  "id"=>"xxx-id-of-team-1"},
        "away"=>
          {"name"=>"Indiana Pacers",
               "alias"=>"IND",
                  "id"=>"yyy-id-of-team-2"},
      }]
  end
  let (:game_details) do
    { 'id' => "aaa-id-of-game-1",
      'status' => 'inprogress',
      'period' => "2",
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
                        "statistics" => {"assists" => "2.0", "steals" => "4", "rebounds" => "6" }
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
      @contest = FactoryGirl.create(:contest, contest_start: Time.now - 60,
                                    contestdate: Time.now.to_date)

      @lineup = create(:lineup, user: user)
      @lineup2 = create(:lineup, user: user2)

      @entry = create(:entry, contest: @contest, lineup: @lineup)
      @entry = create(:entry, contest: @contest, lineup: @lineup2)

      # will get a games update, players update, and an entry update message
      pusher_mock.should_receive(:trigger).exactly(3).times do |event, msg|
         event.should == 'stats'
         @games = msg['games'] unless !msg['games']
         @playermsg = msg['players'] unless !msg['players']
         @entries = msg['entries'] unless !msg['entries']
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
    end
    # we'll be getting 4 player stats per player, so 8 stats total
    it { PlayerRealTimeScore.all.should have(8).items }
    it "will contain update for 2 players" do
      @playermsg.should have(2).items
    end
    it "should includes fantasypoints for both players" do
      expect(@playermsg[0][:currfps]).to eq(9)
      expect(@playermsg[1][:currfps]).to eq(18)
    end
    it "will have an entry" do
      expect(@entries).to be_true
      expect(@entries.length).to eq(2)
      expect(@entries[0]['id']).to be > 0
    end
  end

  context "called two times with no change" do
    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # expect a games msg and a player message (no second set of messages)
      mock_channel.should_receive(:trigger).exactly(2).times do | event, msg |
        puts "received #{msg}"

      end
 
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
    end

    it "contains stats for 2 players" do
      PlayerRealTimeScore.all.should have(8).items
    end
  end

  context "called two times with changes in scores" do

    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # receive push msg 3x (games, players, entries) during initial call to refresh_schedule/game,
      # then 3x for second refresh.
      mock_channel.should_receive(:trigger).exactly(3).times.ordered do |event, msg|
        puts "received #{msg}"
      end
      mock_channel.should_receive(:trigger).exactly(3).times.ordered do |event, msg|
        puts "second block, received #{msg}"
         @playermessage = msg['players'] unless !msg['players']
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
      # change a player's steals
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'][0]['statistics']['steals'] = 82
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)
    end

    it "message should contain update for one player" do
      @playermessage.should have(1).items
    end
    it "message should include fantasy points" do
      expect(@playermessage[0][:currfps]).to eq(169)
    end
    it "message should include realtime stats update with 82 steals" do
      expect(@playermessage[0][:rtstats]).to match(/82 S/)
    end
  end

  context "when there are 30 player changes" do

    it "should not exceed 50 stats/msg" do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # with 30 changes, 3 stats per msg, plus fantasy point stat, there are 120 messages to send.
      # That means 3 Pusher messages, plus 1 for the entries message.
      mock_channel.should_receive(:trigger).exactly(4).times do |event, msg|
        @playermsg = msg['players'] unless !msg['players']
        # BUGBUG: WHY AREN"T THERE 30 UPDATES??
      end
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'] = []  # clear out old value.
      game_src1['team'][1]['players']['player'] = []  # clear out old value.
      30.times do |idx|
        game_src1['team'][0]['players']['player'] <<
            { "id" => "a",
               "statistics" => {"assists" => (15+idx).to_s, "steals" => (15+idx*2).to_s,
                                "rebounds" => (15+idx*3).to_s }
             }
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)
      @playermsg.count.should <= 50
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


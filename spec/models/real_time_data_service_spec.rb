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
         @games = msg[:games] unless !msg[:games]
         @playermsg = msg[:players] unless !msg[:players]
         @entries = msg[:entries] unless !msg[:entries]
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
    end
    # we'll be getting 4 player stats per player, so 8 stats total
    it { PlayerRealTimeScore.all.should have(8).items }
    it "will contain update for 2 players" do
      @playermsg.should have(2).items
    end
    it "has the right realtime stats for both players" do
      expect(@playermsg[0][:rtstats]).to eq("3R 1A 2S")
      expect(@playermsg[1][:rtstats]).to eq("6R 2A 4S")
    end
    it "have correct fantasypoints calculated for both players" do
      #NBA	Fantasy pts
      #Point	 1.00     Rebound	 1.25     Assist	 1.50
      #Steal	 2.00     Block	 2.00       Turnover	 (1.00)
      expect(@playermsg[0][:currfps]).to eq(3*1.25+1*1.5+2*2)
      expect(@playermsg[1][:currfps]).to eq(6*1.25+2*1.5+4*2)
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
      @msgs = []
      mock_channel.should_receive(:trigger).exactly(3).times.ordered do |event, msg|
        @msgs << msg
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
      # change a player's steals
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'][0]['statistics']['steals'] = 82
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)
    end

    it "will result in game, player, and player update messages" do
      @msgs.should have(3).items
      expect(@msgs[0]).to have_key(:games)
      expect(@msgs[1]).to have_key(:players)
      expect(@msgs[2]).to have_key(:players)
    end
    it "message should include fantasy points" do
      expect(@msgs[2][:players][0][:currfps]).to eq(169)
    end
    it "message should include realtime stats update with 82 steals" do
      expect(@msgs[2][:players][0][:rtstats]).to match(/82 S/)
    end
  end

  context "when there are 80 player changes" do

    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      # with 80 changes, there are 80 messages to send.
      # That means 2 Pusher messages, plus 1 for the games message.
      mock_channel.should_receive(:trigger).exactly(3).times do |event, msg|
        @playermsgs << msg[:players] unless !msg[:players]
      end
      @playermsgs = []
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'] = []  # clear out old value.
      game_src1['team'][1]['players']['player'] = []  # clear out old value.
      80.times do |idx|
        game_src1['team'][0]['players']['player'] <<
            { "id" => "a#{idx}",
              "statistics" => {"assists" => (15+idx).to_s, "steals" => (15+idx*2).to_s,
                               "rebounds" => (15+idx*3).to_s }
            }
      end
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)

    end
    it "will send one msg with 50, and one with 30" do
      expect(@playermsgs[0].count).to be(50)
      expect(@playermsgs[1].count).to be(30)
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


require 'spec_helper'

describe RealTimeDataService do
  let(:now) { Time.parse("2014-03-18 17:51:27 -0000")}
  let(:todaydate) { now.to_date }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:positions) { create_list(:sport_position, 6)}
  let(:pgpos) { SportPosition.find_by_name('PG')}
  let!(:players) {  create_list(:player, 3, sport_position: pgpos) }
  let(:pusher_mock) { double('channel') }

  let(:lineups) { [create(:lineup, user: user), create(:lineup, user: user2)] }
  let(:contest) { create(:contest,
                         contestdate: todaydate) }
  let!(:entries) { [create(:entry, contest: contest, lineup: lineups[0]),
                    create(:entry, contest: contest, lineup: lineups[1])]}

  let!(:game) { create(:game_score, ext_game_id: "aaa-id-of-game-1")}
  let(:game_schedule) do
    [{ 'id' => game.ext_game_id,
        'home' => {}, 'away' => {},
        'home_team' => "xxx-id-of-team-1", 'away_team' => "yyy-id-of-team-2",
        'status' => 'inprogress',
        'scheduled' => now - 30.minutes,
        "home"=> {"name"=>"Philadelphia 76ers", "alias"=>"PHI", "id"=>"xxx-id-of-team-1"},
        "away"=> {"name"=>"Indiana Pacers", "alias"=>"IND", "id"=>"yyy-id-of-team-2"},
      }]
  end
  let (:game_details) do
    { 'id' => game.ext_game_id,
      'status' => 'inprogress',
      'period' => "2",
      'clock' => "4:25",
      'team' => [{'points' => "54", 'players' => { 'player'=> [
                      { "id" => players[2].ext_player_id,
                        "statistics" => {"assists" => "1.0", "steals" => "2", "rebounds" => "3" }
                      }]}
                 },
                 {'points' => "22",  'players' => { 'player'=> [
                      { "id" => players[0].ext_player_id,
                        "statistics" => {"assists" => "2.0", "steals" => "4", "rebounds" => "6" }
                      }]
                  }}],
    }
  end
  let(:game_exp) { {:games=>[{"id"=>game.id, "pretty_play_state"=>"48 MIN LEFT",
                              "minutes_remaining"=>48,
                              "home_team_score"=>54, "away_team_score"=>22}]}
  }
  # NBA fantasy point calculation:
  #Point	 1.00     Rebound	 1.25     Assist 1.50   Steal	2.00     Block 2.00  Turnover (1.00)
  # pl2 FPS: 3*1.25+1*1.5+2*2 = 9.25 id1;; pl0 FPS: 6*1.25+2*1.5+4*2 = 18.5
  # entries' fantasypoint scores are all 0 b/c we didn't set up lineups with real players.

  let(:player_exp) {
    {:players=>[{:id=>players[2].id, :rtstats=>"3R 1A 2S", :currfps=>9.25},
                {:id=>players[0].id, :rtstats=>"6R 2A 4S", :currfps=>18.5}]}
  }

  let(:entries_exp) {
    {:entries=>[{"id"=>entries[0].id, "fps"=>0}, {"id"=>entries[1].id, "fps"=>0}]}
  }

  before do
    Pusher.stub(:[]).with('gamecenter').and_return(pusher_mock)
  end

  context "the first time it's called" do
    # we'll be getting 4 player stats per player, so 8 stats total
    it "delivers 8 scores" do
      RealTimeDataService.new.refresh_schedule(game_schedule)
      expect(pusher_mock).to receive(:trigger).with("stats", game_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", player_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp)
      RealTimeDataService.new.refresh_game(game_details)
      expect(PlayerRealTimeScore.all.count).to be(8)
    end
    it "receives correct game update, player update, and entry update" do
      RealTimeDataService.new.refresh_schedule(game_schedule)


      expect(pusher_mock).to receive(:trigger).with("stats", game_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", player_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp)

      RealTimeDataService.new.refresh_game(game_details)
    end
  end

  context "called two times with no change" do
    it "contains stats for 2 players" do
      RealTimeDataService.new.refresh_schedule(game_schedule)
      @gameid = GameScore.find_by_ext_game_id("aaa-id-of-game-1").id

      expect(pusher_mock).to receive(:trigger).with("stats", game_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", player_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp) # why 2 times?

      RealTimeDataService.new.refresh_game(game_details)
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
      PlayerRealTimeScore.all.should have(8).items

    end
  end

  context "called two times with changes in scores" do

    it "will result in game, player, and player update messages with correct stats and fantasy points" do
      # receive push msg 3x (games, players, entries) during initial call to refresh_schedule/game,
      # then 3x for second refresh.
      expect(pusher_mock).to receive(:trigger).with("stats", game_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", player_exp)
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp)
      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_details)
      # change a player's steals
      game_src1 = game_details.clone
      game_src1['team'][0]['players']['player'][0]['statistics']['steals'] = 82

      # create expected results for player
      player_exp2 = player_exp.clone
      player_exp2[:players][0][:rtstats] = "3R 1A 82S"
      player_exp2[:players][0][:currfps] = 169.25
      player_exp2[:players].delete_at(1) # player 1 didn't change, so no update for him.
      expect(pusher_mock).to receive(:trigger).with("stats", player_exp2)
      # entries update when any player updates.
      expect(pusher_mock).to receive(:trigger).with("stats", entries_exp)

      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)
    end
  end

  context "when a new game is scheduled" do
    it "creates a new game entry" do
      pending "We should test this"
    end

  end
  context "when there are 80 player changes" do
    let!(:players) {  create_list(:player, 80, sport_position: pgpos) }

    it "will send one msg with 50, and one with 30" do
      game_src1 = game_details.clone
      @player_extids = Player.all.pluck('ext_player_id')
      expect(@player_extids.count >= 80)
      @player_extids.each_with_index do |extid, idx|
        game_src1['team'][0]['players']['player'] <<
            { "id" => extid,  # this is the ID defined in players' factory
              "statistics" => {"assists" => (15+idx).to_s, "steals" => (15+idx*2).to_s,
                               "rebounds" => (15+idx*3).to_s }
            }
      end
      # with 80 changes, there are 80 messages to send.
      # That means 2 Pusher messages, plus 1 for the games message.
      expect(pusher_mock).to receive(:trigger).once.with("stats", game_exp)
      expect(pusher_mock).to receive(:trigger).once do |event, msg|
        expect(event).to eq("stats")
        expect(msg[:players].count).to be(50)
      end
      expect(pusher_mock).to receive(:trigger).once do |event, msg|
        expect(event).to eq("stats")
        expect(msg[:players].count).to be(30)
      end
      expect(pusher_mock).to receive(:trigger).once.with("stats", entries_exp)

      RealTimeDataService.new.refresh_schedule(game_schedule)
      RealTimeDataService.new.refresh_game(game_src1)

    end
  end

  context "when a contest starts" do
    it 'will receive a contest object over realtimedataservice' do
      pending "need to add this"
    end
  end
end

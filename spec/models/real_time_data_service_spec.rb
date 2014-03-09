require 'spec_helper'

describe RealTimeDataService do
  before { Player.create(ext_player_id: "a") }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:game_src) do
    [ { 'players' => { 'player'=> [ 
          { "id" => "a",
            "statistics" => {"assists" => "1.0", "steals" => "2", "rebounds" => "3" }
          }
        ]
     } } ]
  end

  context "the first time it's called" do
    before do
      mock_channel = double('channel') # rspec object that stands in for another object
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      @contest = FactoryGirl.create(:contest, contest_start: Time.now - 60)

      @lineup = create(:lineup, user: user)
      @lineup2 = create(:lineup, user: user2)

      @entry = create(:entry, contest: @contest, lineup: @lineup)
      @entry = create(:entry, contest: @contest, lineup: @lineup2)

      mock_channel.should_receive(:trigger).twice do |event, msg|
         event.should == 'stats'
         @message = msg['players'] unless !msg['players']
         @entries = msg['entries'] unless !msg['entries']
      end
      RealTimeDataService.new.refresh_game(game_src)
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
      mock_channel.should_receive(:trigger).twice()

      RealTimeDataService.new.refresh_game(game_src)
      RealTimeDataService.new.refresh_game(game_src) 
    end

    it { PlayerRealTimeScore.all.should have(4).items }
  end

  context "caglled again with changes in scores" do

    let(:game_src1) do
      [ { 'players' => { 'player'=> [ 
            { "id" => "a",
              "statistics" => {"assists" => "2.0", "steals" => "2.0", "rebounds" => 3.0 }
            }
          ]
       } } ]
    end

    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger).twice.ordered
      mock_channel.should_receive(:trigger).twice.ordered do |event, msg|
         @message = msg['players'] unless !msg['players']
      end
      RealTimeDataService.new.refresh_game(game_src)
      RealTimeDataService.new.refresh_game(game_src1) 
    end

    it { @message.should have(2).items }
    it "should includes fp" do
      stats = @message.select {|s| s["stat_name"] == "fp"}
      stats.should have(1).items
      stats[0]["stat_value"].should == 10.75
    end
  end

  context "when there are may stats to message" do

    let(:game_src1) do
      1000.times.map do
        { 'players' => { 'player'=> [ 
            { "id" => "a",
              "statistics" => {"assists" => "2.0", "steals" => "2.0", "rebounds" => 3.0 }
            }
          ]
       } }
      end
    end

    it "should not exceed 50 stats/msg" do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger).twice do |event, msg|
         msg['players'].count.should <= 50 unless !msg['players']
      end
      RealTimeDataService.new.refresh_game(game_src1) 
    end

  end
end


require 'spec_helper'

describe RealTimeDataService do
  before { Player.create(ext_player_id: "a") }
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
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger) do |event, msg|
         event.should == 'stats'
         @message = msg['players']
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
  end

  context "called again with no change" do
    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger).once()

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
      mock_channel.should_receive(:trigger).once.ordered
      mock_channel.should_receive(:trigger).once.ordered do |event, msg|
         @message = msg['players']
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
end


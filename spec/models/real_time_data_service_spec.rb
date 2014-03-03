require 'spec_helper'

describe RealTimeDataService do
  before { Player.create(ext_player_id: "a") }
  let(:game_src) do
    [ { 'players' => { 'player'=> [ 
          { "id" => "a",
            "statistics" => {"assists" => 1.0, "steals" => 2.0, "rebounds" => 3.0 }
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

    it { PlayerRealTimeScore.all.should have(3).items }
    it { @message.should have(3).items }
  end

  context "called again with no change" do
    before do
      mock_channel = double('channel')
      Pusher.stub(:[]).with('gamecenter').and_return(mock_channel)
      mock_channel.should_receive(:trigger) do |event, msg|
         event.should == 'stats'
         @message = msg['players']
      end
      RealTimeDataService.new.refresh_game(game_src)
      RealTimeDataService.new.refresh_game(game_src) 
    end

    it { PlayerRealTimeScore.all.should have(3).items }
  end

  context "caglled again with changes in scores" do

  let(:game_src1) do
    [ { 'players' => { 'player'=> [ 
          { "id" => "a",
            "statistics" => {"assists" => 2.0}
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

    it { @message.should have(1).items }
  end
end


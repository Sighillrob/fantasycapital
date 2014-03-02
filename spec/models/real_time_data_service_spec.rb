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

  before { RealTimeDataService.new.refresh_game(game_src) }

  context "the first time it's called" do
    subject { PlayerRealTimeScore.all }
    
    it { should have(3).items }
  end

end


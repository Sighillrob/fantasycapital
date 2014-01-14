module StatsClient
  class Player
    attr_reader :player_id, :first_name, :last_name, :team, :positions
    include StatsClient::BaseResource

    class << self
      def method_name_for_attr(attr)
         {'playerId' => 'player_id', 'firstName' => 'first_name', 'lastName' => 'last_name'}[attr] || attr
      end
    end
  end
end

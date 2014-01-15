module StatsClient
  class Player
    attr_accessor :id, :first_name, :last_name, :team, :positions

    include StatsClient::BaseResource

    def initialize
      @positions = []
    end

    def positions=(positions_collection)
      positions_collection.each do |position_hash|
        position = PlayerPosition.new
        position.copy_instance_variables_from_hash position_hash

        self.positions.push position
      end
    end

    class << self
      def method_name_for_attr(attr)
         {'playerId' => 'id', 'firstName' => 'first_name', 'lastName' => 'last_name'}[attr] || attr
      end
    end
  end
end

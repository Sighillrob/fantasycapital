module StatsClient
  class PlayerPosition
    attr_reader :id, :name, :abbreviation, :sequence
    include StatsClient::BaseResource

    class << self
      def method_name_for_attr(attr)
        {'positionId' => 'id'}[attr] || attr
      end
    end
  end
end

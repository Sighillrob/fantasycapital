module StatsClient
  class PlayerPosition
    attr_reader :id, :name, :abbreviation, :sequence
    include StatsClient::BaseResource

    def method_name_for_attr(attr)
      {'positionId' => 'id'}[attr] || self.class.method_name_for_attr(attr)
    end
  end
end

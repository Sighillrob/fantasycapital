module StatsClient
  class Team
    attr_accessor :id, :name, :location, :abbreviation
    include StatsClient::BaseResource

    class << self
      def method_name_for_attr(attr)
         {'nickname' => 'name', 'teamId' => 'id'}[attr] || super
      end
    end
  end
end


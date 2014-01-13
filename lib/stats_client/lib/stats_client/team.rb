module StatsClient
  class Team
    attr_reader :team_id, :name, :location
    include StatsClient::BaseResource

    class << self
      def method_name_for_attr(attr)
         {'nickname' => 'name', 'teamId' => 'team_id'}[attr] || attr
      end
    end
  end
end


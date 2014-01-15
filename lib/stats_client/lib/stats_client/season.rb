module StatsClient
  class Season
    attr_accessor :season, :name, :active

    include StatsClient::BaseResource

    def active?
      active
    end

    class << self
      def method_name_for_attr(attr)
        { 'isActive' => 'active' }[attr] || attr
      end
    end
  end
end

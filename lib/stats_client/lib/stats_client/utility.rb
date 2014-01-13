module StatsClient
  class Utility
    class << self
      def get_formatted_date(date)
        date.to_date.strftime "%Y-%d-%m"
      end
    end
  end
end
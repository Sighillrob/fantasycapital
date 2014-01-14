module StatsClient
  module ResponseParser
    class DatetimeParser

      class << self 
        def parse(datetime_node)
          DateTime.parse datetime_node.select {|d| d['dateType'] == 'UTC'}.first['full'] + "+00:00"
        end
      end

    end
  end
end

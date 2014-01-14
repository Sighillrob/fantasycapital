module StatsClient
  # stats account secret
  mattr_accessor :api_secret

  mattr_accessor :api_key
  @@base_url = 'http://api.stats.com/v1'.freeze

  mattr_accessor :logger
  class << self
    def configure
      yield self
    end

    def base_url
      @@base_url
    end

    def logger
     @@logger ||= ::Logger.new('log/stats_client.log')
    end
  end
end

require 'stats_client/stats_gateway'
require 'stats_client/base_resource'
require 'stats_client/response'
require 'stats_client/team'
require 'stats_client/failure_response'
require 'stats_client/success_response'
require 'stats_client/response_parser/base_parser'
require 'stats_client/client'
require 'stats_client/player'
require 'stats_client/sports/football'
require 'stats_client/sports/basketball'

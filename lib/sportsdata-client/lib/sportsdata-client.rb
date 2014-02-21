require 'active_support/all'
require 'httparty'

module SportsdataClient
  # stats account secret
  mattr_accessor :api_secret

  mattr_accessor :api_key
  @@base_url = 'http://api.sportsdatallc.org/'.freeze

  mattr_accessor :logger
  class << self
    def configure
      yield self
    end

    def base_url
      @@base_url
    end

    def logger
     @@logger ||= ::Logger.new('log/sportsdata-client.log')
    end
  end
end

require 'sportsdata-client/client'
require 'sportsdata-client/response_parser'
require 'sportsdata-client/response'
require 'sportsdata-client/success_response'
require 'sportsdata-client/failure_response'
require 'sportsdata-client/sportsdata_gateway'
require 'sportsdata-client/sports/nba'

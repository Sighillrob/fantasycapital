require 'httparty'

module StatsClient
  class Client
    include HTTParty
    logger StatsClient.logger, :info, :apache
    base_uri StatsClient.base_url
    default_params accept: 'json'

    attr_reader :action_prefix

    def request(action, params = {}, &block)
      params.merge! sig: generate_stats_signature, api_key: StatsClient.api_key

      parse_response self.class.get(api_url(action), query: params), &block
    end

    protected
    def initialize(action_prefix)
      @action_prefix = action_prefix
    end

    def generate_stats_signature
     digest_string = StatsClient.api_key + StatsClient.api_secret + Time.now.utc.to_i.to_s
     digest        = Digest::SHA256.new
     digest.update(digest_string).to_s
    end

    def api_url(action)
       "/#{action_prefix}/#{action}"
    end

    def parse_response(response, &block)
      if response.success?
        results = yield response['apiResults'] if block_given?
        StatsClient::SuccessResponse.new response.body, results
      else
        StatsClient::FailureResponse.new response.body, response.body
      end
    end
  end
end

require 'httparty'

module StatsClient
  class Client
    RETRY_DELAY = 3
    RETRIES = 5

    include HTTParty
    debug_output $stderr if Rails.env.development?
    #logger StatsClient.logger, :info, :apache
    base_uri StatsClient.base_url
    default_params accept: 'json'

    attr_reader :action_prefix

    def request(action, params = {}, &block)
      params.merge! sig: generate_stats_signature, api_key: StatsClient.api_key

      params.delete_if { |k, v| v.nil? || v.empty? }

      response = with_retries { self.class.get(api_url(action), query: params) }
      parse_response response, &block
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

    def with_retries(&block)
      begin
        RETRIES.times do
          response = yield
          case response.code
          when 500...600
            puts "sleeping for for retry"
            sleep RETRY_DELAY
          else
            return response
          end
          response
        end
      rescue Errno::ECONNREFUSED, SocketError, Net::ReadTimeout
        puts "sleeping for for retry"
        sleep RETRY_DELAY
        retry
      end
    end
    
  end
end

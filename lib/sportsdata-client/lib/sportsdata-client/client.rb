require 'httparty'

module SportsdataClient
  class Client
    RETRY_DELAY = 3
    RETRIES = 5

    include HTTParty
    debug_output $stderr if Rails.env.development?
    #logger SportsdataClient.logger, :info, :apache
    base_uri SportsdataClient.base_url

    attr_reader :action_prefix

    def request(action, params = {}, &block)
      params.delete_if { |k, v| v.nil? || v.empty? }
      raw_response = self.class.get(api_url(action), query: params)
      response = with_retries { raw_response }
      parse_response raw_response, response, &block
    end

    protected
    def initialize(action_prefix)
      @action_prefix = action_prefix
    end

    def api_url(action)
       "/#{action_prefix}/#{action}"
    end

    def parse_response(http_request, response, &block)
      if http_request.success?
        results =  block_given? ? yield(response['apiResults']) : response['apiResults']
        SportsdataClient::SuccessResponse.new response, results
      else
        SportsdataClient::FailureResponse.new response, response
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

module SportsdataClient
  class SportsdataGateway
    cattr_reader :client

    def initialize

    end

    class << self
      def client
        @@client ||= SportsdataClient::Client.new  self.action_prefix
      end
    end
  end
end

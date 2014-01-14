module StatsClient
  module Sports
    module Basketball
      class NBA < StatsClient::StatsGateway

        class << self
          # @return Array of Team(name, location, abbreviation, and ID).
          def teams(season= nil)
             client.request 'teams/' do |response|
               StatsClient::ResponseParser::BaseParser.new(response, StatsClient::Team).parse 'teams'
             end
          end

          def players
            client.request 'participants/' do |response|
              StatsClient::ResponseParser::BaseParser.new(response, StatsClient::Player).parse 'teams'
            end
          end

          # Find team by ID
          def fetch_team(team_id, season= nil)
            #client.request "/teams/#{team_id}"
          end

          protected
          def action_prefix
            'stats/basketball/nba'
          end
        end
      end

    end
  end
end

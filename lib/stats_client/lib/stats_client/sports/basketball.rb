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
              StatsClient::ResponseParser::BaseParser.new(response, StatsClient::Player).parse 'players'
            end
          end

          def player_game_by_game_stats(player_id)
            client.request "stats/players/#{player_id}/events/" do |response|
              StatsClient::ResponseParser::SimpleParser.new(response).parse 'events'
            end
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

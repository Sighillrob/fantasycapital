module SportsdataClient
  module Sports
      class NBA < SportsdataClient::SportsdataGateway

        class << self
          def teams(season= nil)
            client.request 'league/hierarchy.xml' do |response|
              SportsdataClient::ResponseParser.new(response).parse 'team'
            end
          end

          def players(team_id)
            client.request "teams/#{team_id}/profile.xml" do |response|
                SportsdataClient::ResponseParser.new(response).parse 'player'
            end
          end

          def games(season, nba_season)
            client.request "games/#{season}/#{nba_season}/schedule.xml" do |response|
                SportsdataClient::ResponseParser.new(response).parse 'game'
            end
          end

          def game_stats(game_id)
            client.request "games/#{game_id}/summary.xml" do |response|
                SportsdataClient::ResponseParser.new(response).parse 'team'
            end
          end

          def games_scheduled(date=Time.now)
            client.request "games/#{date.strftime("%Y/%m/%d")}/schedule.xml" do |response|
              SportsdataClient::ResponseParser.new(response).parse 'game'
            end
          end
          
          protected
          def action_prefix
            'nba-t3'
          end
        end
      end

    end
  end

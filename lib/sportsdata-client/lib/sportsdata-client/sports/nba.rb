module SportsdataClient
  module Sports
      class NBA < SportsdataClient::SportsdataGateway

        class << self
          def current_season
            season = (Time.now.month < 10) ? Time.now.year - 1 : Time.now.year
          end

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

          def regular_season_games(season=current_season)
            games(season, 'REG')
          end

          def post_season_games(season=current_season)
            games(season, 'PST')
          end 

          def games(season, nba_season)
            client.request "games/#{season}/#{nba_season}/schedule.xml" do |response|
                SportsdataClient::ResponseParser.new(response).parse 'game'
            end
          end

          def full_game_stats(game_id)
            client.request "games/#{game_id}/summary.xml"
          end

          def game_stats(game_id)
            client.request "games/#{game_id}/summary.xml" do |response|
                SportsdataClient::ResponseParser.new(response).parse 'team'
            end
          end

          def games_scheduled(date=Time.now.in_time_zone("EST"))
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

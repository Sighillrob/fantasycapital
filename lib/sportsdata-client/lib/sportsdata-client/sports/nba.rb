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
          

          #######

          def player_game_by_game_stats(player_id)
            client.request "stats/players/#{player_id}/events/" do |response|
              SportsdataClient::ResponseParser::SimpleParser.new(response).parse 'events'
            end
          end

          def player_stats(player_id, season=nil, event_type=nil)
            params = {season: season, event_type: event_type}

            client.request "stats/players/#{player_id}/", params do |response|
              SportsdataClient::ResponseParser::ResponseParser.new(response, SportsdataClient::Stats::PlayerStats).parse 'players'
            end
          end

          def team_stats(team_id)
            client.request "stats/teams/#{team_id}/" do |response|
              SportsdataClient::ResponseParser::ResponseParser.new(response, SportsdataClient::Stats::TeamStats).parse 'teams'
            end
          end

          def events(date=Time.now)
            client.request "events/?date=#{date.strftime("%Y-%m-%d")}" do |response|
              SportsdataClient::ResponseParser::SimpleParser.new(response).parse 'events'
            end
          end

          def sports_for_today
            date = SportsdataClient::Utility.get_formatted_date Time.now
            client.request "events/", date: date do |response|
              SportsdataClient::ResponseParser::ResponseParser.new(response, SportsdataClient::Sport).parse 'events', parent_attributes: 'sportId'
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

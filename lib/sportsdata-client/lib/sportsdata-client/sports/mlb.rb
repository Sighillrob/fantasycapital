module SportsdataClient
  module Sports
      class MLB < SportsdataClient::SportsdataGateway

        class << self

          def current_season
            # MLB season runs from April thru Sept in regular season, Oct post-season.
            season = Time.now.year
          end

          def teams(season=current_season)
            teams=client.request "teams/#{season}.xml" do |response|
              SportsdataClient::ResponseParser.new(response).parse 'team'
            end
            process_mlb_teams teams

          end

          def players(ext_team_ids, season=current_season)
            # NOTE: in MLB, 'ext_team_ids' variable is unused b/c the API returns all teams
            # regardless, while in NBA we have to make an API call per team.
            # return a hash of external team ids, with each entry an array of parsed players
            players={}
            client.request "rosters/#{season}.xml" do |response|
              teams_parsed=SportsdataClient::ResponseParser.new(response).parse 'team'

              teams_parsed.each do |team_parsed|
                # parse out 'player' nodes from each team.
                players_parsed = SportsdataClient::ResponseParser.new
                players[team_parsed['id']] = players_parsed.parse('player', team_parsed)
              end
            end
            players
          end

          def all_season_games(season=current_season)
            events = client.request "schedule/#{season}.xml" do |response|
              SportsdataClient::ResponseParser.new(response).parse 'event'
            end
            process_mlb_events events
          end

          def full_game_stats(game_id)
            #client.request "games/#{game_id}/summary.xml"
            client.request "statistics/#{game_id}.xml"
          end

          def game_stats(game_id)
            # Get "Game Summary" from API
            # For Projection, this needs to return array of length 2, each entry is a “team” hash:
            #id — team ID
            #[players][player]
            #    [played]
            #    [id] (player ID)
            #    [statistics]
            #        [stat1]
            #        [stat2]
            result = client.request "statistics/#{game_id}.xml"
            hometeamstats = result['statistics']['home']
            awayteamstats = result['statistics']['visitor']

            # adjust parameters to match receiver's expectations
            [hometeamstats,awayteamstats].each do |teamstats|

              teamstats['hitting']['players']['player'].each do |player|
                # BUGBUG: PITCHER IS MISSING HERE, NEED TO ADD hometeamstats['pitching]['players']

                player['played'] = player['games']['play'].to_i > 0 ? 'true' : 'false'
                player['statistics'] = {}

                # Add "onbase" statistics -- single, double, triple, homerun, base-on-balls,
                #   hit-by-pitch
                ['s', 'd', 't', 'hr', 'bb', 'hbp'].each do |statname|
                  player['statistics'][statname] = player['onbase'][statname]
                end
                # Append other stats
                player['statistics']['runs'] = player['runs']['total']  # total runs
                player['statistics']['rbi'] = player['rbi']             # RBI
                player['statistics']['ktotal'] = player['outs']['ktotal'] # strikeouts
                player['statistics']['stolen'] = player['steal']['stolen'] # stolen bases

              end
            end
            # return home and away team, similar format as NBA API does natively.
            teamresp = [{'id' => hometeamstats['id'], 'players' => hometeamstats['hitting']['players']},
                        {'id' => awayteamstats['id'], 'players' => awayteamstats['hitting']['players']}]

            return teamresp

          end

          def games_scheduled(date=Time.now.in_time_zone("EST").to_date)
            url =  "daily/schedule/%04d/%02d/%02d.xml" % [date.year, date.month, date.day]
            events = client.request url do |response|
              SportsdataClient::ResponseParser.new(response).parse 'event'
            end
            process_mlb_events events
          end
          
          protected
          def action_prefix
            'mlb-t4'
          end

          def process_mlb_teams(teams)
            # take teams coming from the sports-data API for MLB,
            # and adjust their fields so the rest of the app understands them
            teams.each do |team|
              team['alias'] = team['abbr']
            end
            return teams
          end
          def process_mlb_events(events)
            # take events (aka games)coming from the sports-data games API for MLB,
            # and adjust their fields so the rest of the app understands them
            events.each do |event|
              event['scheduled'] = event['scheduled_start']
              event['home_team'] = event['home']
              event['away_team'] = event['visitor']
            end
            return events
          end
        end
      end

    end
  end

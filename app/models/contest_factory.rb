class ContestFactory
  NBA_CONTESTS = [
      ["50/50", 1.00, 9.00, 10],
      ["50/50", 2.00, 18.00, 10],
      ["50/50", 5.00, 45.00, 10],
      ["50/50", 10.00, 90.00, 10],
      ["50/50", 25.00, 225.00, 10],
      ["50/50", 50.00, 450.00, 10],
      ["50/50", 100.00, 900.00, 10],
      ["50/50", 250.00, 225.00, 10],
      ["50/50", 500.00, 450.00, 10],
      ["H2H", 1.00, 9.00, 10],
      ["H2H", 2.00, 18.00, 10],
      ["H2H", 5.00, 45.00, 10],
      ["H2H", 10.00, 90.00, 10],
      ["H2H", 25.00, 225.00, 10],
      ["H2H", 50.00, 450.00, 10],
      ["H2H", 100.00, 900.00, 10],
      ["H2H", 250.00, 2250.00, 10],
      ["H2H", 500.00, 4500.00, 10],
      ["Tournament", 1.00, 90.00, 100],
      ["Tournament", 2.00, 180.00, 100],
      ["Tournament", 5.00, 450.00, 100],
      ["Tournament", 10.00, 900.00, 100],
      ["Tournament", 25.00, 2250.00, 100],
      ["Tournament", 50.00, 4500.00, 100],
      ["Tournament", 100.00, 9000.00, 100],
      ["Tournament", 250.00, 22500.00, 100],
      ["Tournament", 500.00, 45000.00, 100]
  ] 

  class << self

    def create_nba_contests
      # create games and contests for all days where there are 3 or more games being played.

      # generate hash of how many games are played on each date.
      games_per_day = GameScore.recent_and_upcoming.group(:playdate).uniq.count
      games_per_day.each do |gamedate, gamecount |
        # skip days with fewer than 3 games.
        next if gamecount < 3

        # generate contests for this gamedate if they don't exist yet.
        games_of_day = GameScore.where(playdate:gamedate)

        # contests start at the earliest gametime of that day.
        contest_time = games_of_day.pluck(:scheduledstart).sort()[0].to_time

        # create array of all teams playing today.
        p_teams = games_of_day.map {|g| [g.home_team, g.away_team]}.flatten

        players = p_teams.reduce([]) {|p, t| p + Player.where(
                                    ext_player_id: t.players.map {|pp| pp.ext_player_id})}

        # Seed the 'fp' (fantasypoint) score of each player playing today. This makes our
        # queries in GameCenter work (we need at least one PlayerRealTimeScore for us to get
        # list of players)
        games_of_day.each { |game|
          players_in_game = game.home_team.players.to_a.concat game.away_team.players.to_a
          players_in_game.each { |pl|
            PlayerRealTimeScore.where(player: pl, name: "fp", value: 0.0,
                                              game_score:game).first_or_create

          }
        }
        
        # Create contests for this day, and mark eligible players, if they don't already exist.
        NBA_CONTESTS.each do |row|
          c = Contest.where(contest_type: row[0], entry_fee: row[1], prize: row[2],
                          max_entries: row[3], sport: "NBA", contestdate:gamedate).first_or_initialize
          c.contest_start = contest_time
          c.save! if c.changed?
          # Create a playercontest entry per player and contest. So it's ~6K entries per day.
          # this keeps the logic general (we could make some players not eligible for a given day).
          # we might want to optimize what's stored in a playercontest (e.g. remove the statistics)
          # or find a way to do a batch update. This is expensive in the DB at the moment, at least
          # in dev machine.
          players.each do |p|
            # we've seen bad sport position data get in, which means a nil sport-position. In that
            # case, remove the player contest
            # if it exists so we don't have weird invalid playercontest entries.
            # TODO: we can remove this check later, b/c there's now a validation check on player
            #  that sports position can't be nil. but don't remove it until we're sure there
            #  is no bad data in DB.
            if p.sport_position_id.nil?
              PlayerContest.where(player: p).destroy_all  # destroy for old contests too.. he will screw us up.
            else
              PlayerContest.where(contest: c, player: p).first_or_create
            end
          end
          puts "Created PlayerContests for #{players.count} players for contest #{c.id}"
        end
      end
    end

    private 

    def contest_start_time(date)
      date
    end

    def contest_end_time(date)
      date.in_time_zone("EST").beginning_of_day.change({hour: 23})
    end

  end
end
  
   

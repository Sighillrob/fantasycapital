class ContestFactory
  NBA_CONTESTS = [
      ["50/50", 1.00, 9.50, 10],
      ["50/50", 2.00, 19.00, 10],
      ["50/50", 5.00, 47.50, 10],
      ["50/50", 10.00, 95.00, 10],
      ["50/50", 25.00, 237.50, 10],
      ["50/50", 50.00, 475.00, 10],
      ["50/50", 100.00, 950.00, 10],
      ["50/50", 250.00, 2375.00, 10],
      ["50/50", 500.00, 4750.00, 10],
      ["H2H", 1.00, 9.50, 10],
      ["H2H", 2.00, 19.00, 10],
      ["H2H", 5.00, 47.50, 10],
      ["H2H", 10.00, 95.00, 10],
      ["H2H", 25.00, 237.50, 10],
      ["H2H", 50.00, 475.00, 10],
      ["H2H", 100.00, 950.00, 10],
      ["H2H", 250.00, 2375.00, 10],
      ["H2H", 500.00, 4750.00, 10],
      ["Tournament", 1.00, 95.00, 100],
      ["Tournament", 2.00, 190.00, 100],
      ["Tournament", 5.00, 475.00, 100],
      ["Tournament", 10.00, 950.00, 100],
      ["Tournament", 25.00, 2375.00, 100],
      ["Tournament", 50.00, 4750.00, 100],
      ["Tournament", 100.00, 9500.00, 100],
      ["Tournament", 250.00, 23750.00, 100],
      ["Tournament", 500.00, 47500.00, 100]
  ] 

  class << self

    def create_nba_contests(games_src)
      #populate contests only when there are 3 or more games for the day
      return if games_src.nil? || games_src.count < 3
      p_teams = Projection::Team.includes(:players).where(ext_team_id: games_src.reduce([]) {|teams, game| teams + [game['home_team'], game['away_team']]})
      players = p_teams.reduce([]) {|p, t| p + Player.where(ext_player_id: t.players.map {|pp| pp.ext_player_id})}

      contest_date = Time.parse(games_src[0]["scheduled"])
      NBA_CONTESTS.each do |row|
        c = Contest.create(contest_type: row[0], entry_fee: row[1], prize: row[2], max_entries: row[3], sport: "NBA", contest_start: contest_start_time(contest_date), contest_end: contest_end_time(contest_date))
        players.each do |p|
          PlayerContest.where(contest: c, player: p).first_or_create
        end
      end
    end

    private 

    def contest_start_time(date)
      date.in_time_zone('America/New_York').beginning_of_day.change({hour: 19})
    end

    def contest_end_time(date)
      date.in_time_zone('America/New_York').beginning_of_day.change({hour: 23})
    end

  end
end
  
   

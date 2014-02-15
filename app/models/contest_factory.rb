class ContestFactory
  NBA_CONTESTS = [
      ["50/50", 1.00, 9.50, 10],
      ["50/50", 2.00, 19.00, 10],
      ["50/50", 5.00, 47.50, 10],
      ["50/50", 10.00, 95.00, 10],
      ["50/50", 25.00, 237.50, 10],
      ["50/50", 50.00, 475.00, 10],
      ["50/50", 100.00, 950.00, 10],
      ["50/50", 250.00, 2,375.00, 10],
      ["50/50", 500.00, 4,750.00, 10],
      ["H2H", 1.00, 9.50, 10],
      ["H2H", 2.00, 19.00, 10],
      ["H2H", 5.00, 47.50, 10],
      ["H2H", 10.00, 95.00, 10],
      ["H2H", 25.00, 237.50, 10],
      ["H2H", 50.00, 475.00, 10],
      ["H2H", 100.00, 950.00, 10],
      ["H2H", 250.00, 2,375.00, 10],
      ["H2H", 500.00, 4,750.00, 10],
      ["Tournament", 1.00, 95.00, 100],
      ["Tournament", 2.00, 190.00, 100],
      ["Tournament", 5.00, 475.00, 100],
      ["Tournament", 10.00, 950.00, 100],
      ["Tournament", 25.00, 2,375.00, 100],
      ["Tournament", 50.00, 4,750.00, 100],
      ["Tournament", 100.00, 9,500.00, 100],
      ["Tournament", 250.00, 23,750.00, 100],
      ["Tournament", 500.00, 47,500.00, 100]
  ] 

  class << self

    def create_nba_contests(date=Time.now)
      NBA_CONTESTS.each do |row|
        Contest.create(contest_type: row[0], entry_fee: row[1], prize: row[2], max_entries: row[3], sport: "NBA", contest_start: contest_start_time(date))
      end
    end

    private 

    def contest_start_time(date)
      date.in_time_zone('America/New_York').beginning_of_day.change({hour: 19})
    end

  end
end
  
   

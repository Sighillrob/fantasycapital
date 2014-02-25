namespace :stats do
   def log(message, error = false)
     if error
       Rails.logger.error message
     else
       Rails.logger.info message
     end
     puts message
   end
  # Invoking rake tasks in a graceful way. Prevents rake tasks defined below
  # from crashing.
  def safe_rake_tasks(task)
    begin
      log "#{task} started at #{Time.now}"
      eval "Rake::Task['#{task}'].reenable"
      eval "Rake::Task['#{task}'].invoke"
      log "#{task} completed successfully at #{Time.now}"
    rescue Exception => e
      log "#{task} failed at #{Time.now}", true
    end
  end


  desc "Daily task"
  task daily_task: [:environment] do
    safe_rake_tasks "stats:fetch_contests"
    safe_rake_tasks "stats:fetch_players"
  end

  desc "Populate contests from stats api"
  task fetch_contests: [:environment] do
    ContestFactory.create_nba_contests SportsdataClient::Sports::NBA.games_scheduled(Time.now).result
  end

  desc "Populate players for NBA from SportsData api"
  task fetch_players: [:environment] do
    teams = SportsdataClient::Sports::NBA.teams.result
    teams.each do |team|
      Player.refresh_all SportsdataClient::Sports::NBA.players(team['id']).result, team
    end
  end

  desc "Populate player's historical stats"
  task stats: [:environment] do
    Projection::ScheduledGame.where("start_date > ?", 1.days.ago).each do |scheduled_game|
      StatService.new.update_player_stats(scheduled_game)
    end
  end

  task dummy_stats: [:environment ] do
    PlayerStat.delete_all
    Player.all.each do |player|
      ["summary", "matchup"].each do |dim|
        ["12/1", "11/24", "11/17", "Home Games", "Away Games", "2013 Season"].each do |span|
          ["MPG", "RPG", "APG", "BLKPG", "STLPG", "PFPG", "TOPG", "PPG", "FPPG"].each do |stat|
            PlayerStat.create(dimension: dim, time_span: span, stat_name: stat, stat_value: "10.0", player: player)
          end
        end
      end
    end
  end

end

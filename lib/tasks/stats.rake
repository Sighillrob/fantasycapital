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
    safe_rake_tasks "stats:fetch_players"
    safe_rake_tasks "stats:create_contests"
    safe_rake_tasks "stats:player_stats"
  end

  desc "Create games and contests from stats api"
  task create_contests: [:environment] do
    today = Time.now.in_time_zone("EST").to_date
    # create games and contests for multiple days in future so that we can always have contests to
    # enter.
    ActiveRecord::Base.logger.level = 2   # disable logging all SQL calls to console.
    (today.. today+4).each do |date|
      games_scheduled = SportsdataClient::Sports::NBA.games_scheduled(date).result
      RealTimeDataService.new.refresh_schedule games_scheduled
    end
    # populate upcoming contests in main webapp
    ContestFactory.create_nba_contests

  end

  desc "Populate players for NBA from SportsData api"
  task fetch_players: [:environment] do
    teams = SportsdataClient::Sports::NBA.teams.result
    teams.each do |team|
      Player.refresh_all SportsdataClient::Sports::NBA.players(team['id']).result, team
    end
  end

  desc "Populate player's historical stats"
  task player_stats: [:environment] do
    Projection::ScheduledGame.games_on.each do |scheduled_game|
      Resque.enqueue(PlayerStatsWorker, scheduled_game.id)
    end
  end

  task dummy_stats: [:environment ] do
    PlayerStat.delete_all
    Player.all.each do |player|
      ["summary", "matchup"].each do |dim|
        ["MPG", "RPG", "APG", "BLKPG", "STLPG", "PFPG", "TOPG", "PPG", "FPPG"].each do |stat|
          priority=0
          ["12/1", "11/24", "11/17", "Home Games", "Away Games", "2013 Season"].each do |span|
            PlayerStat.create(dimension: dim, time_span: span, stat_name: stat, stat_value: "10.0", player: player, display_priority: priority+=1)
          end
        end
      end
    end
  end

end

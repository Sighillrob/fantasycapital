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
    response = SportsdataClient::Sports::NBA.games_scheduled(Time.now)
    #populate contests only when there are 3 or more games for the day
    if response.success? && response.result.count >= 3
      ContestFactory.create_nba_contests
    end
  end

  desc "Populate players for NBA from SportsData api"
  task fetch_players: [:environment] do
    teams = SportsdataClient::Sports::NBA.teams.result
    teams.each do |team|
      Player.refresh_all SportsdataClient::Sports::NBA.players(team['id']).result, team
    end
  end

end

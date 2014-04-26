
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

  desc "Populate players for all active sports from SportsData API"
  task fetch_players: [:environment] do
    SPORTS.each do |sport_name, sport|
      Rails.logger.info "Rake stats fetch players for #{sport_name}"
      teams = sport[:api_client].teams
      Team.refresh_all(teams)
      players_in_teams = sport[:api_client].players(teams)
      players_in_teams.each do |team_id, players|
        Player.refresh_all players, team_id, sport_name
      end
    end
    Rails.logger.info "Rake stats fetch players finished"
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


   desc "Populate player's historical stats"
  task player_stats: [:environment] do
    Projection::ScheduledGame.games_on.each do |scheduled_game|
      Resque.enqueue(PlayerStatsWorker, scheduled_game.id)
    end
  end


end

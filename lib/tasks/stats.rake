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
    ContestFactory.create_nba_contests
  end

  desc "Populate players for NBA from stats api"
  task fetch_players: [:environment] do
    response = StatsClient::Sports::Basketball::NBA.players
    if response.success?  
      response.result.each do |p|
        #TODO: we'll update this for all sports soon, for now we are focusing on NBA only
        Rails.logger.info "creating player with stats ID #{p.id}"
        player  = Player.where(stats_id: p.id).first_or_create
        player.refresh! p
        player.save
      end

    end
  end

end

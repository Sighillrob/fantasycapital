
namespace :realtime do

  desc "Check if realtime-data task should be started. This task should be run from heroku scheduler ~once per hour. "
  task check_start_realtime: :environment do
    now = Time.now
    today = now.in_time_zone("US/Pacific").to_date

    puts "Checking whether to start realtime service for #{today}"
    games = GameScore.in_range(today, today).not_closed.order(scheduledstart: :asc)
    if games.count.zero?
      puts "... no unclosed games today. Returning"
    else
      firststart = games.first.scheduledstart
      puts "First game scheduled start = #{firststart}"
      puts "Now is #{now}"
      # if the first game starts within a few hours, turn on RTdata. Note this will fire even when RTdata is already
      # running, but that's harmless even in corner cases.
      if  now + 3.hours > firststart
        puts "Starting / ensuring RTdata is running..."
        heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
        heroku.post_ps_scale(Rails.configuration.app_name, 'rtdata', 1)
      end
    end
  end

  desc "Get realtime game stats for all games for one day. This task will be launched daily by check_start_realtime "
  task games: :environment do
    # Monitor all live games from one process and thread to economize on DB connections.
    today = Time.now.in_time_zone("US/Pacific").to_date
    puts "Starting realtime game status for #{today}"

    # manage a list of games for today that aren't complete yet.


    # update all games that are in progress every 20 seconds, while any games are in progress.
    loop do
      games = GameScore.in_range(today, today).not_closed
      break if games.length == 0
      puts "Running realtime game status for #{games.length} games for #{today}"

      # repeat polling games multiple times before checking if any games have 'closed' again.
      6.times do
        timerthread = Thread.new do
          puts "Sleeping 20 sec"
          sleep 20
          puts "Done sleeping 20 sec"
        end

        now = Time.now

        # iterate through games. Delete games from the list if they've closed. Update them with new
        # API data if they are in progress.
        game_closed_with_score = false
        players_somewhere_changed = false
        games.each do |game|
          next if game.scheduledstart - 15.minutes > now
          puts "Updating game #{game.away_team.teamalias}@#{game.home_team.teamalias}"
          game, a_player_changed = RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(game.ext_game_id).result['game']
          game_closed_with_score = true if game.closed? and !game.exception_ending?
          players_somewhere_changed = true if a_player_changed
        end

        # send entries to browser
        if players_somewhere_changed
          RealTimeDataService.new.refresh_entries today
        end

        # if one of the games just closed, see if we can close out any contests

        if game_closed_with_score
          puts "A game just closed... trying to close contests"
          RealTimeDataService.new.try_closing_contests today
          puts "Done closing contests"
        end

        timerthread.join

      end
    end

    # all games for day are done - turn off the dyno.
    puts "All games done for today. Shutting off realtime worker"
    heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
    heroku.post_ps_scale(Rails.configuration.app_name, 'rtdata', 0)

  end

  # NILS: Deprecated -- this built the schedule AND monitored games.
  #task games_old: :environment do
  #
  #  while true do
  #    begin
  #      puts "Realtime task: fetching games"
  #      ongoing_ext_games = RealTimeDataService.new.refresh_schedule SportsdataClient::Sports::NBA.games_scheduled.result
  #      ongoing_ext_games.each do |ext_game|
  #        RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(ext_game['id']).result['game']
  #      end
  #      sleep 15
  #    rescue => e
  #      Rails.logger = Logger.new(STDOUT)
  #      Rails.logger.error e.message
  #      Rails.logger.error e.backtrace.join("\n")
  #    end
  #  end
  #end

  desc "capture realtime game stats and save them to files"
  task games_to_file: :environment do
    while true do
      begin
        ts = Time.now.strftime("%d-%H-%M-%S")
          Projection::ScheduledGame.games_on.each do |game|
          File.open("tmp/#{ts}__#{game.ext_game_id}.json","w") do |f|
            f.write(SportsdataClient::Sports::NBA.full_game_stats(game.ext_game_id).result.to_json)
          end
        end
        sleep 150
      rescue => e
        logger.error e.message
        logger.error e.backtrace.join("\n")
      end
    end
  end

  desc "play back game stats from saved json files"
  task games_playback: :environment do
    if !File.directory?("#{Rails.root}/db/gamefeeds")
      `cd db && tar xzvf gamefeeds.tgz`
    end

    # map captured games to real games in play, by ext_game_id

    Dir.entries( "#{Rails.root}/db/gamefeeds").select {|f| !File.directory? f}.map{|x| x[0..10]}.uniq.sort.each do |ts|
      Dir["#{Rails.root}/db/gamefeeds/#{ts}*"].each do |feed|
        puts "Sending file #{feed}"
        game_json = JSON.parse(File.open(feed).read)['game']
        # IDs of the "fake" games in DB is "FAKE-" + real_game_id
        game_json['id'] = "FAKE-" + game_json['id']
        RealTimeDataService.new.refresh_game game_json
      end
      RealTimeDataService.new.refresh_entries "2050-12-31"
      sleep 1
    end
    # reset all fake games status back to scheduled so that next time they will run again
    GameScore.where("ext_game_id like ?", "FAKE-%").update_all(status: "scheduled")
  end

end

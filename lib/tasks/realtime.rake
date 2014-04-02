
namespace :realtime do
  desc "Poll games APIs every 15s when games are in progress"

  desc "Get realtime game stats for all games for one day. This task should be launched daily. "
  task games: :environment do
    # Monitor all live games from one process and thread to economize on DB connections.
    today = Time.now.in_time_zone("EST").to_date

    # manage a list of games for today that aren't complete yet.
    games = GameScore.in_range(today, today)
    puts "Running realtime game status for #{games.length} games for #{today}"

    # update all games that are in progress every 20 seconds, while any games are in progress.
    while games.length > 0 do

      timerthread = Thread.new do
        puts "Sleeping 20 sec"
        sleep 20
        puts "Done sleeping 20 sec"
      end

      now = Time.now

      # iterate through games. Delete games from the list if they've closed. Update them with new
      # API data if they are in progress.
      games.delete_if do |game| game.closed? end
      games.each do |game|
        next if game.scheduledstart - 15.minutes > now
        puts "Updating game #{game.away_team.teamalias}@#{game.home_team.teamalias}"
        retgame = RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(game.ext_game_id).result['game']
      end

      timerthread.join

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
    games_captured = Dir.entries( "#{Rails.root}/db/gamefeeds").select {|f| !File.directory? f}.map{|x| x[13..48]}.uniq
    games_in_play = GameScore.where(scheduledstart: Time.now..Time.now+1.day).map {|x| x.ext_game_id}
    num_games = [games_captured.size, games_in_play.size].min
    id_map = Hash[games_captured[0,num_games].zip(games_in_play[0,num_games])]

    Dir.entries( "#{Rails.root}/db/gamefeeds").select {|f| !File.directory? f}.map{|x| x[0..10]}.uniq.sort.each do |ts|
      Dir["#{Rails.root}/db/gamefeeds/#{ts}*"].each do |feed|
        puts "Sending file #{feed}"
        game_json = JSON.parse(File.open(feed).read)['game']
        game_json['id'] = id_map[game_json['id']]
        RealTimeDataService.new.refresh_game game_json
      end
      sleep 1
    end
  end

end

namespace :realtime do
  desc "Poll games APIs every 15s when games are in progress"
  task games: :environment do

    while true do
      begin
        ongoing_games = RealTimeDataService.new.refresh_schedule SportsdataClient::Sports::NBA.games_scheduled.result
        ongoing_games.each do |game|
          RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(game['id']).result['game']
        end
        sleep 15
      rescue => e
        Rails.logger = Logger.new(STDOUT)
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end

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

    Dir.entries( "#{Rails.root}/db/gamefeeds").select {|f| !File.directory? f}.map{|x| x[0..7]}.uniq.sort.each do |ts|
      Dir["#{Rails.root}/db/gamefeeds/#{ts}*"].each do |feed|
        puts "Sending file #{feed}"
        RealTimeDataService.new.refresh_game JSON.parse(File.open(feed).read)['game']
      end
      sleep 1
    end
  end

end

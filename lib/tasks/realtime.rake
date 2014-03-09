namespace :realtime do
  desc "Poll games APIs every 15s when games are in progress"
  task games: :environment do
    while true do
      begin
        SportsdataClient::Sports::NBA.games_scheduled.result.select {|g| g['status'] == 'inprogress'}.each do |game|
          RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.game_stats(game['id']).result
        end
        sleep 15
      rescue => e
        logger.error e.message
        logger.error e.backtrace.join("\n")
      end
    end
  end

  desc "capture realtime game stats and save them to files"
  task games_to_file: :environment do
    while true do
      ts = Time.now.strftime("%H-%M-%S")
      SportsdataClient::Sports::NBA.games_scheduled.result.select {|g| g['status'] == 'inprogress'}.each do |game|
        File.open("tmp/#{ts}__#{game['id']}.json","w") do |f|
          f.write(SportsdataClient::Sports::NBA.game_stats(game['id']).result.to_json)
        end
      end
      sleep 150
    end
  end

  desc "Send dummy stats to webscoket client every 15s"
  task dummy_games_refresh: :environment do
    v = 0.0
    u = 0.0
    while true
      msg = [ { "id" => 118, "stat_name" => 'points', "stat_value" => v+=1.0 },
              { "id" => 394, "stat_name" => 'points', "stat_value" => u+=3.0 },
              { "id" => 118, "stat_name" => 'fp', "stat_value" => v * 2 },
              { "id" => 394, "stat_name" => 'fp', "stat_value" => u * 2 }
      ]
      Rails.logger.info "sending #{msg}"
      puts "sending #{msg}"
      Pusher['gamecenter'].trigger('stats', { "players" => msg })

      sleep 5

    end
  end

end

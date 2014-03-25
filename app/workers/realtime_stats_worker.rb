class RealtimeStatsWorker
  include Sidekiq::Worker
  def perform(game_id)
    puts "Sidekiq worker for game id #{game_id} starting"

    while true do
      game = RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(game_id).result['game']
      # prevent stray worker (for whatever reason) by exiting after 8 hours
      break if game.closed? or Time.now > (game.scheduledstart + 8.hours)
      sleep 15
    end
    puts "Sidekiq worker for game id #{game_id} ending"
    puts "Game is closed" if game.closed? else "Game NOT closed"

  end
end


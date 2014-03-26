class RealtimeStatsWorker
  include Sidekiq::Worker

  # workers are currently a little unreliable. Let them restart pretty often and pretty quickly
  # because if a worker exhausts its retries, we are no longer processing a game's realtime updates.
  sidekiq_options :retry => 200
  sidekiq_retry_in do |count|
    30 + (count * 5)
  end

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end


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


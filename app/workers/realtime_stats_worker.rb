class RealtimeStatsWorker
  include Sidekiq::Worker
  def perform(game_id)
    while true do
      game = RealTimeDataService.new.refresh_game SportsdataClient::Sports::NBA.full_game_stats(game_id).result['game']
      # prevent stray worker (for whatever reason) by exiting after 8 hours
      return if game.closed? or Time.now > (game.scheduledstart + 8.hours)
      sleep 15
    end
  end
end


class FPCalculationWorker
  @queue = :fp_calculation
  def self.perform(scheduled_game_id)
    Projection::FantasyPointCalculator.new.update Projection::ScheduledGame.find(scheduled_game_id)
  rescue Resque::TermException
    Resque.enqueue(self, scheduled_game_id)
  end
end

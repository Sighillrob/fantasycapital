class PlayersController < ApplicationController
  def stats
  	@summary = {}
  	@matchup = {}
  	@player = Player.find(params[:id])
  	@summary_time_spans = PlayerStat.where("player_id = ? AND dimension = ?", params[:id], 'summary').group('time_span').select('time_span').all
  	@summary_time_spans.each do |time_span|
  		stat_line = PlayerStat.player_stat_line @player.id, 'summary', time_span.time_span
  		@summary[time_span.time_span] = stat_line
  	end

  	@matchup_time_spans = PlayerStat.where("player_id = ? AND dimension = ?", params[:id], 'matchup').group('time_span').select('time_span').all
  	@matchup_time_spans.each do |time_span|
  		stat_line = PlayerStat.player_stat_line @player.id, 'matchup', time_span.time_span
  		@matchup[time_span.time_span] = stat_line
  	end

    render layout: false
  end
end

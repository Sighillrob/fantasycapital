module ProjectionByStatsHelper
  def stat_of(projection, stat_name)
    projection.projection_by_stats.select {|s| s.stat_name == stat_name}[0]
  end

  def lookup_stat(stats, event_id, player, stat_name)
    stats.each do |s|
      if s.game.stats_event_id == event_id && s.player.eql?(player) && s.stat_name == stat_name
        return s
      end
    end
    return nil
  end
end

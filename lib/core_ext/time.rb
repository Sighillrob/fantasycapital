class Time
  def in_est
    self.in_time_zone('America/New_York')
  end
end

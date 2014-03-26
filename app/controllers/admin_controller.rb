class AdminController < ApplicationController

  layout "admin"  # use admin.html.erb as base layout

  def index
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

  end

  def games
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

    @games = GameScore.in_range(todaydate-3, todaydate+10)
  end

end

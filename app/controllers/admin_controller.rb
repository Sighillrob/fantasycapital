class AdminController < ApplicationController

  def index
    puts "HI"
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

    @games = GameScore.in_range(todaydate-10, todaydate+10)
  end

end

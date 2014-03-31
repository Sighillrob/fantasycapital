class AdminController < ApplicationController
  before_action :require_admin!

  layout "admin"  # use admin.html.erb as base layout

  def index
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

  end

  def games
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

    @games = GameScore.in_range(todaydate-3, todaydate+10)
  end

  def users
    @users = User.all
  end

  private
    def require_admin!
      # check if user has 'admin' bit set in their profile.
      redirect_to main_app.root_url unless current_user.try(:admin?)
    end

end

class ContestController < ApplicationController
  def index
    @contests = Contest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contests}
    end
  end
end

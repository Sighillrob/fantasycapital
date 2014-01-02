class WaitingListsController < ApplicationController
 skip_before_action :restrict_to_splash_page

  # GET /waiting_lists/new
  def new
    @waiting_list = WaitingList.new
  end

  # POST /waiting_lists
  def create
    @waiting_list = WaitingList.new(waiting_list_params)

    if @waiting_list.save
      redirect_to splash_path, notice: 'Waiting list was successfully created.'
    else
      render action: 'new'
    end
  end
  private

  # Only allow a trusted parameter "white list" through.
  def waiting_list_params
    params.require(:waiting_list).permit(:email, :name)
  end
end

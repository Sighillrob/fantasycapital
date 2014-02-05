class InviteWorker
  include Sidekiq::Worker

  def perform(params, user_id)
  	params["emails"].split(',').each do |email|
  		waitinglist=WaitingList.new
  		waitinglist.email = email
  		waitinglist.user_id = user_id
  		waitinglist.message = params["message"]
  		waitinglist.save
  	end
  end
end
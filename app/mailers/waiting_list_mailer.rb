class WaitingListMailer < FantasyMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.waiting_list_mailer.invite.subject
  #
  def invite(waiting_list)
  	@invitee = waiting_list.user if waiting_list.user
    @waiting_list =  waiting_list
    mail to: @waiting_list.email, from:'softmfq@gmail.com'
  end
end

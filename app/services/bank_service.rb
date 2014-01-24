class BankService

  attr_reader :bank_account

  def initialize(user, stripe_token)
    @user = user
    @stripe_token = stripe_token
  end

  def add(bank_params)
    @bank_account = @user.bank_accounts.build(bank_params)

    recipient = Stripe::Recipient.create(
      :name => @user.full_name, # This is the user's full legal name
      :type => "individual",
      :email => @user.email,
      :bank_account => @stripe_token
    )

    @bank_account.recipient_id = recipient.id
    @bank_account.save
  end
end

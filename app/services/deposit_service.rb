class DepositService

  def initialize(user)
    @user = user
  end

  def deposit(amount)

    # Dirty safety check
    raise 'Amount is wrong!' unless amount > 0

    amount = amount * 100 # Needs to be in cents

    charge = Stripe::Charge.create(
      customer: @user.account.stripe_customer_id,
      amount: amount,
      description: 'Fantasy Capital Deposit',
      currency: 'usd'
    )

    # We really need to think about how we are going to handle this. 
    begin
      @user.account.balance_in_cents = @user.account.balance_in_cents + amount
      @user.account.save!
      @user.account.balance_in_cents # For locking
    rescue ActiveRecord::StaleObjectError
      @user.account.reload
      retry
    end
  end
end

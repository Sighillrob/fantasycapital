MIN_DEPOSIT_AMOUNT = 20
MAX_DEPOSIT_AMOUNT = 2000

class DepositService

  def initialize(user)
    @user = user
  end

  def deposit(amount)

    unless amount >= MIN_DEPOSIT_AMOUNT && amount <= MAX_DEPOSIT_AMOUNT
      raise DepositError, "Amount must be between $#{MIN_DEPOSIT_AMOUNT} - $#{MAX_DEPOSIT_AMOUNT}"
    end

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

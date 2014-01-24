MIN_DEPOSIT_AMOUNT = 20
MAX_DEPOSIT_AMOUNT = 2000

class DepositService

  def initialize(user)
    @user = user
  end

  def deposit(amount)
    validate_amount!(amount)
    amount = amount * 100 # Needs to be in cents

    charge = Stripe::Charge.create(
      customer: @user.account.stripe_customer_id,
      amount: amount,
      description: 'Fantasy Capital Deposit',
      currency: 'usd'
    )

    @user.add_to_balance(amount)
  end

  private

  def validate_amount!(amount)
    unless amount >= MIN_DEPOSIT_AMOUNT && amount <= MAX_DEPOSIT_AMOUNT
      raise ServiceError, "Amount must be between $#{MIN_DEPOSIT_AMOUNT} - $#{MAX_DEPOSIT_AMOUNT}"
    end
  end

end

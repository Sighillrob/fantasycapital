MIN_WITHDRAWAL_AMOUNT = 20

class BankWithdrawalService

  def initialize(user, bank)
    @user = user
    @bank = bank
  end

  def withdraw(amount)

    if amount < MIN_WITHDRAWAL_AMOUNT
      raise ServiceError, "You must withdraw at least $#{MIN_WITHDRAWAL_AMOUNT}"
    end

    cents = amount * 100

    if cents > @user.account.balance_in_cents
      raise ServiceError, 'Insufficient Funds'
    end

    Stripe::Transfer.create(
      amount: cents,
      currency: 'usd',
      recipient: @bank.recipient_id,
      statement_descriptor: 'Fantasy Capital Bank Tranfer'
    )

    @user.reduce_balance(cents)
  end
end

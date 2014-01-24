# This handles ensuring the the user has an associated stripe customer. It will
# create one and assign it to the user if it is not present. It will be reused
# for credit card creation, bank account creation, etc.
class StripeCustomerService

  def initialize(user, stripe_token)
    @user = user
    @stripe_token = stripe_token
  end

  def ensure!
    begin
      if @user.account
        customer = Stripe::Customer.retrieve(@user.account.stripe_customer_id)
      else
        customer = Stripe::Customer.create(
          email: @user.email,
          card: @stripe_token
        )
        @user.account = Account.new(stripe_customer_id: customer.id)
        @user.save!
      end
    rescue Stripe::InvalidRequestError => e
      raise ServiceError, e.message
    end
  end
end


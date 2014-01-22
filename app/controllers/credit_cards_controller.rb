class CreditCardsController < ApplicationController

  def create

    credit_card = current_user.credit_cards.build(credit_card_params)
    # First card is always the default
    credit_card.is_default = current_user.credit_cards.where(is_default: true).none?

    begin

      stripe_token = params[:stripe_token]

      if current_user.account
        customer = Stripe::Customer.retrieve(current_user.account.stripe_customer_id)
      else
        customer = Stripe::Customer.create(
          email: current_user.email,
          card: stripe_token
        )
        current_user.account = Account.new(stripe_customer_id: customer.id)
        current_user.save!
      end

      if params[:amount].present?
        amount = params[:amount].gsub(/\D/, '').to_i
        DepositService.new(current_user).deposit(amount)
      end

      if credit_card.save
        render json: {status: 201}
      else
        render json: credit_card.errors, status: :unprocessable_entity
      end
    rescue Stripe::CardError => e
      render json: {error: e.message}, status: :unprocessable_entity
    end
  end

  private

  def credit_card_params
     params.require(:credit_card).permit(:stripe_id, :card_brand, :last_four)
  end
end

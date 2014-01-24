# Handles adding new credit cards to an existing customer account cards
class CardService

  attr_reader :credit_card

  def initialize(user)
    @user = user
  end

  def add(card_params)
    @credit_card = @user.credit_cards.build(card_params)
    @credit_card.is_default = @user.credit_cards.where(is_default: true).none?
    @credit_card.save
  end
end

# Even thoug this is called credit card we only maintain the stripe ID
# and the last 4 digits of the card. The real numbers never touch our servers
class CreditCard < ActiveRecord::Base
  belongs_to :user
  validates :stripe_id, presence: true
  validates :last_four, presence: true
  validates :card_brand, presence: true
end

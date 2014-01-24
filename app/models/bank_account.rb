class BankAccount < ActiveRecord::Base
  belongs_to :user
  validates :stripe_id, presence: true
  validates :last_4, presence: true
  validates :name, presence: true
  validates :recipient_id, presence: true
end

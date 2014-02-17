# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  balanced_customer_id   :string(255)
#  balance                :integer          default(0)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :lineups, inverse_of: :user
  has_one :waiting_list
  has_one :account
  has_many :credit_cards
  has_many :bank_accounts
  has_many :entries, through: :lineups
  has_many :contests, through: :entries

  validates :first_name, :last_name, presence: true

  after_create :attach_waiting_list

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def add_to_balance(cents)
    raise 'Cents must be positive or zero!' unless cents >= 0
    self.adjust_balance(cents)
  end

  def reduce_balance(cents)
    raise 'Cents must be positive or zero!' unless cents >= 0
    self.adjust_balance(-cents)
  end

  def account_balance
    return 0 unless self.account
    self.account.current_balance
  end

  def default_card
    self.credit_cards.where(is_default: true).first
  end

  # We need to think about how we are going to handle this in the safest possible way
  def adjust_balance(cents)
    begin
      self.account.balance_in_cents = self.account.balance_in_cents + cents
      self.account.save!
      self.account.balance_in_cents # For locking
    rescue ActiveRecord::StaleObjectError
      self.account.reload
      retry
    end
  end

  def invitation_token
    waiting_list.invitation_token
  end

  protected
  def attach_waiting_list
    unless waiting_list
      build_waiting_list
    end
  end
end

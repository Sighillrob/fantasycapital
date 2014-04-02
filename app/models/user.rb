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
#  username               :string(255)
#  country                :string(255)
#  state                  :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable


  has_many :lineups, inverse_of: :user
  has_one :waiting_list
  has_one :account
  has_many :credit_cards
  has_many :bank_accounts
  has_many :entries, through: :lineups
  has_many :contests, through: :entries
  has_many :transactions, inverse_of: :user

  validates :first_name, :last_name, :country, :state, presence: true
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :email
  validates_uniqueness_of :email

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
    transaction_list = Transaction.where(user_id: self.id)


    #########################################################################
    # Temporary code - REMOVE when we have real code to add transactions
    if transaction_list.length == 0
      # Create random number of transactions for current user
      n_to_create = rand(10..30)
      (0..n_to_create).each do
        rx = Transaction.random_transaction(self)
        if rx != nil
          rx.save
        end
      end

      # Negative balance?
      begin
        # DANGER - recursion!!  But it's only temp code...
        bal = self.account_balance
      rescue
        # Create a couple of positive transaction types
        rx = Transaction.random_transaction(self, 
                                            force_transaction_type = 1)
        rx.save
        retry
      end
      transaction_list = Transaction.where(user_id: self.id)
    end
    # END Temporary code to create random transactions
    ###########################################################################


    bal_in_cents = 0
    transaction_list.each do |ttt|
      bal_in_cents += ttt.amount_in_cents
    end
    raise 'Users cannot have a negative balance' unless bal_in_cents >= 0
    return bal_in_cents / 100.0
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

# == Schema Information
#
# Table name: accounts
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  type           :string(255)
#  ext_account_id :string(255)
#  balance        :decimal(10, 2)
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :account do
    stripe_customer_id 'cus_123'
    balance_in_cents 0
  end
end

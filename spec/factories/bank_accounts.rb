FactoryGirl.define do
  factory :bank_account do
    name 'test bank'
    last_4 '1234'
    recipient_id 'r123'
    stripe_id 's123'
  end
end

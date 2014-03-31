# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    amount_in_cents 1
    transaction_type 1
    user_id 1
    parent_transaction_id 1
    payment_engine_type 1
    payment_engine_id "MyString"
    notes "MyText"
  end
end

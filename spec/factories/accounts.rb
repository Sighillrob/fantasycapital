# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    user nil
    type ""
    ext_account_id "MyString"
  end
end

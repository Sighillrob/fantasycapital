# == Schema Information
#
# Table name: waiting_lists
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  invited_by_id   :integer
#  invited_by_type :string(255)
#  invitation_code :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :waiting_list do
    email "MyString"
    name "MyString"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team, :class => 'Projection::Team' do
    name "MyString"
  end
end

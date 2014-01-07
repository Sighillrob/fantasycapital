# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_stat, :class => 'Projection::Stat' do
    stat_name "MyString"
    stat_value "9.99"
    references ""
    references ""
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_projection_breakdown, :class => 'Projection::ProjectionBreakdown' do
    proj_by_stat_crit nil
    stat nil
  end
end

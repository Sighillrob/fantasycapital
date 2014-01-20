class Projection::ProjectionBreakdown < ActiveRecord::Base
  belongs_to :proj_by_stat_crit
  belongs_to :stat
end

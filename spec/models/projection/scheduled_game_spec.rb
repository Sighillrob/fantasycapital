# == Schema Information
#
# Table name: projection_scheduled_games
#
#  id             :integer          not null, primary key
#  home_team_id   :integer
#  away_team_id   :integer
#  start_date     :datetime
#  stats_event_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Projection::ScheduledGame do
  pending "add some examples to (or delete) #{__FILE__}"
end

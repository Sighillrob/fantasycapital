# == Schema Information
#
# Table name: projection_games
#
#  id               :integer          not null, primary key
#  start_date       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  team_id          :integer
#  opponent_team_id :integer
#  stats_event_id   :integer
#

require 'spec_helper'

describe Projection::Game do
  pending "add some examples to (or delete) #{__FILE__}"
end

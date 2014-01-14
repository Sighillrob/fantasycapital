# == Schema Information
#
# Table name: projection_games
#
#  id           :integer          not null, primary key
#  gamedate     :datetime
#  is_home      :boolean
#  created_at   :datetime
#  updated_at   :datetime
#  home_team_id :integer
#  away_team_id :integer
#

require 'spec_helper'

describe Projection::Game do
  pending "add some examples to (or delete) #{__FILE__}"
end

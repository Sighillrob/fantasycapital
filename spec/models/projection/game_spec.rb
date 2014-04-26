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
#  ext_game_id      :string(255)
#  home_team_id     :integer
#  away_team_id     :integer
#  sport            :string(255)      default("NBA")
#

require 'spec_helper'

describe Projection::Game do
  pending "add some examples to (or delete) #{__FILE__}"
end

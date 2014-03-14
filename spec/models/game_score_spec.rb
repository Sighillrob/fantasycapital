# == Schema Information
#
# Table name: game_scores
#
#  id              :integer          not null, primary key
#  playdate        :date
#  ext_game_id     :string(255)
#  scheduledstart  :datetime
#  home_team_id    :integer
#  away_team_id    :integer
#  home_team_score :integer
#  away_team_score :integer
#  status          :string(255)
#  clock           :integer
#  period          :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe GameScore do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: projection_teams
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  stats_team_id :integer
#  is_current    :boolean
#

require 'spec_helper'

describe Projection::Team do
  pending "add some examples to (or delete) #{__FILE__}"
end

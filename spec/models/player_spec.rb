# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  team       :string(255)
#  position   :string(255)
#  age        :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Player do
  pending "add some examples to (or delete) #{__FILE__}"
end

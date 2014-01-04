# == Schema Information
#
# Table name: waiting_lists
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  invited_by_id   :integer
#  invited_by_type :string(255)
#  invitation_code :string(255)
#

require 'spec_helper'

describe WaitingList do
  pending "add some examples to (or delete) #{__FILE__}"
end

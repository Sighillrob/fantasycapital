# == Schema Information
#
# Table name: accounts
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  type           :string(255)
#  ext_account_id :string(255)
#  balance        :decimal(10, 2)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Account do
  pending "add some examples to (or delete) #{__FILE__}"
end

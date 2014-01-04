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

class WaitingList < ActiveRecord::Base

  belongs_to :invited_by, polymorphic: true

  validates :email, uniqueness: true

  before_create :generate_invitation_code

  def to_param
    invitation_token
  end
  private

  def generate_invitation_code
    token = loop do
      token = SecureRandom.hex(6)
      break token if WaitingList.where(invitation_token: token ).blank?
    end

    self.invitation_token = token
  end
end

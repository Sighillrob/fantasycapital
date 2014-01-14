# == Schema Information
#
# Table name: waiting_lists
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  invited_by_token :string(255)
#  invitation_token :string(255)
#  status           :integer          default(1)
#  user_id          :integer
#

class WaitingList < ActiveRecord::Base
  module InvitationStatus
    WAITING = 1
    INVITED = 2
    JOINED  = 3
  end

  belongs_to :user

  validates :email, uniqueness: true, presence: true

  before_create :generate_invitation_code

  def to_param
    invitation_token
  end

  def invite!
    WaitingListMailer.invite(self).deliver
    update_attributes status: InvitationStatus::INVITED
  end

  def invited?
    status == InvitationStatus::INVITED
  end

  def joined?
    status == InvitationStatus::JOINED
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

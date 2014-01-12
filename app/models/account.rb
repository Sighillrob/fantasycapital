class Account < ActiveRecord::Base
  belongs_to :user
  validates :ext_account_id, presence: true
end

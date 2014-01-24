require 'spec_helper'
require 'stripe_mock'

describe StripeCustomerService do

  before { StripeMock.start }
  after { StripeMock.stop }

  let(:user) { FactoryGirl.create(:user) }
  let(:user_with_account) { FactoryGirl.create(:user_with_account) }
  let(:stripe_token) { 'stripe_12345' }

  describe 'ensure!' do

    it 'sets stripe id on user for valid token' do
      StripeCustomerService.new(user, stripe_token).ensure!
      user.account.should_not be_nil
    end

    it 'wraps stripe error as a service error' do
      stripe_error = Stripe::InvalidRequestError.new('Token is invalid', 'token')
      StripeMock.prepare_error(stripe_error, :new_customer)
      expect { 
        StripeCustomerService.new(user, stripe_token).ensure! 
      }.to raise_error(ServiceError, 'Token is invalid')
    end
  end
end

require 'spec_helper'

describe Account do
  describe 'balance_in_cents' do

    it 'nil balance should be zero' do
      Account.new.current_balance.should == 0.0
    end

    it 'returns correct balance' do
      Account.new(:balance_in_cents => 5000).current_balance.should == 50.0
    end
  end
end


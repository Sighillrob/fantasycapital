require 'spec_helper'

describe AccountController do
    let(:user) { create(:user) }
    let(:player) { create(:player) }

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in :user, user
    end

  describe "GET 'add_fund'" do
    it "returns http success" do
      get 'add_fund'
      response.should be_success
    end
  end

end

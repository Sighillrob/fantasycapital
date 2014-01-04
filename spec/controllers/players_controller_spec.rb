require 'spec_helper'

describe PlayersController do

  describe "GET 'stats'" do
    let(:user) { create(:user) }
    let(:player) { create(:player) }

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in :user, user
    end

    it "returns http success" do
      get 'stats', { id: player.id }
      response.should be_success
    end
  end

end

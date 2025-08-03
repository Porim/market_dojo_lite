require 'rails_helper'

RSpec.describe "Analytics", type: :request do
  let(:buyer) { create(:user, :buyer) }

  before { sign_in buyer }

  describe "GET /analytics" do
    it "returns http success" do
      get analytics_path
      expect(response).to have_http_status(:success)
    end
  end
end

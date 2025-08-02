require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let(:user) { create(:user, :buyer, password: 'password123') }

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns user data with API token" do
        post api_v1_auth_login_path, params: {
          email: user.email,
          password: 'password123'
        }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq(user.email)
        expect(json['api_token']).to eq(user.api_token)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post api_v1_auth_login_path, params: {
          email: user.email,
          password: 'wrong_password'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end
  end

  describe "GET /api/v1/auth/profile" do
    context "with valid token" do
      it "returns user profile" do
        get api_v1_auth_profile_path, headers: {
          'Authorization' => "Bearer #{user.api_token}"
        }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq(user.email)
      end
    end

    context "without token" do
      it "returns unauthorized" do
        get api_v1_auth_profile_path

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/auth/regenerate_token" do
    it "regenerates API token" do
      old_token = user.api_token

      post api_v1_auth_regenerate_token_path, headers: {
        'Authorization' => "Bearer #{user.api_token}"
      }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['api_token']).not_to eq(old_token)
      expect(user.reload.api_token).not_to eq(old_token)
    end
  end
end

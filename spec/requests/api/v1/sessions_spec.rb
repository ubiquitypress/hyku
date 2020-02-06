require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :request do

  let!(:user) { create(:user) }
  let!(:account) { create(:account) }

  after(:each) do
    travel_back
    user.destroy
  end

  describe "#login" do
    it 'should return jwt token with valid credentials' do
      post api_v1_user_login_url(tenant_id: account.id),  params: {
      email: user.email,
      password: user.password,
      expire: 2
    }

      parse_response = JSON.parse(response.body)
      expect(parse_response.keys).to contain_exactly("email", "token")
      expect(parse_response['email']).to eq(user.email)
      expect(parse_response['token']).to be_truthy
    end
  end

  describe "failed login" do
    it 'should not be able to generate jwt token with invalid credentials' do
      post "/api/v1/tenant/#{account.id}/users/login", params: {
       email: '',
       password: user.password,
       expire: 2
     }

     parse_response = JSON.parse(response.body)
     expect(parse_response['status']).to eq(401)
     expect(parse_response['message']).to eq("Please check that email or password is not wrong")

    end
  end

  describe "Expired tokens" do
    it 'should return empty string or error message with expired token' do
      post api_v1_user_login_url(tenant_id: account.id),  params: {
        email: user.email,
        password: user.password,
        expire: 2
      }

      parse_response = JSON.parse(response.body)
      token = parse_response['token']

      travel_to(Time.now + 4.minute) do
        headers =  {"Authorization" => "Bearer #{token} ", "ACCEPT" => "application/json"}
        get "/api/v1/tenant/#{account.id}/users/log_out", :headers => headers

        if response.body.present?
          response_hash = JSON.parse(response.body)
          expect(response_hash['status']).to eq(401)
          expect(response_hash['message']).to eq("Invalid token")
        else
          expect(response.body).to be_empty
        end
      end

    end
  end

  describe "refresh jwt tokens" do
    it "should be able to refresh a valid unexpired token" do
      post api_v1_user_login_url(tenant_id: account.id),  params: {
        email: user.email,
        password: user.password,
        expire: 10
      }

      parse_response = JSON.parse(response.body)
      token = parse_response['token']

      travel_to(Time.now + 7.minute) do
        headers =  {"Authorization" => "Bearer #{token}", "ACCEPT" => "application/json"}
        post "/api/v1/tenant/#{account.id}/users/refresh", :headers => headers
        response_hash = JSON.parse(response.body)
        expect(response_hash.keys).to contain_exactly("email", "token")
        expect(response_hash['email']).to eq(user.email)
        expect(response_hash['token']).to be_truthy
        expect(response_hash['token']).not_to eq(parse_response['token'])
      end
    end
  end


end

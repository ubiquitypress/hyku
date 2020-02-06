require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :request do

  let!(:user) { create(:user) }
  let!(:account) { create(:account) }

  after(:each) do
    travel_back
  end

  describe "#login" do
    it 'process api post request' do
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
    it 'fails to login' do
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
    it 'rejects request with expired token' do
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
        response_hash = JSON.parse(response.body)
        puts "tani #{response.content_type.inspect}"
        puts "vago #{response.body.inspect}"
        expect(response_hash['status']).to eq(401)
        expect(response_hash['message']).to eq("Invalid token")
      end

    end
  end

end

require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :request do
  include ApiTestHelpers
  let!(:user) { create(:user) }
  let!(:account) { create(:account) }

  before do
    allow(AdminSet).to receive(:all).and_return([])
  end

  after(:each) do
    travel_back
    user.destroy
  end

  describe "#login" do
    it 'should return jwt token with valid credentials if user is confirmed' do
      user.confirm
      post_request(user, 2)
      parse_response = JSON.parse(response.body)
      response_values = response
      returned_cookie = response.cookies.with_indifferent_access[:jwt]
      cookie_value = returned_cookie
      expect(parse_response['email']).to eq(user.email)
      expect(returned_cookie).to be_truthy
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
     returned_cookie = response.cookies.with_indifferent_access[:jwt]

     expect(parse_response['status']).to eq(401)
     expect(parse_response['message']).to eq("This is not a valid token, in order to refresh you must send back a valid token or you must re-log in")
     expect(returned_cookie).to be_falsey
    end

    it 'should not return jwt token with valid credentials if user is not confirmed' do
      post_request(user, 2)
      parse_response = JSON.parse(response.body)
      response_values = response
      returned_cookie = response.cookies.with_indifferent_access[:jwt]
      cookie_value = returned_cookie
      expect(parse_response['status']).to eq(401)
      expect(parse_response['message']).to eq("This is not a valid token, in order to refresh you must send back a valid token or you must re-log in")
      expect(returned_cookie).to be_falsey
    end
  end

  describe "Logout and expire tokens" do
    it 'should return empty string or error message with expired token' do
      post_request(user, 2)
      parse_response = JSON.parse(response.body)
      returned_cookie = response[ "Set-Cookie"]
      travel_to(Time.now + 4.minute) do
        headers =  {Cookie: "#{returned_cookie}", "ACCEPT" => "application/json"}
        get "/api/v1/tenant/#{account.id}/users/log_out", :headers => headers
            expired_cookie = response.cookies.with_indifferent_access[:jwt]
        expect(expired_cookie).to be_falsey
      end

    end
  end

  # describe "refresh jwt tokens" do
  #   it "should be able to refresh a valid unexpired token" do
  #     post_request(user, 10)
  #     parse_response = JSON.parse(response.body)
  #     returned_cookie = response[ "Set-Cookie"]
  #     travel_to(Time.now + 7.minute) do
  #       headers =  {"Cookie" => "#{returned_cookie}", "ACCEPT" => "application/json"}
  #       post "/api/v1/tenant/#{account.id}/users/refresh", :headers => headers
  #       response_hash = JSON.parse(response.body)
  #       new_cookie = response.cookies.with_indifferent_access[:jwt]
  #       expect(response_hash.keys).to contain_exactly("email")
  #       expect(response_hash['email']).to eq(user.email)
  #       expect(new_cookie).to be_truthy
  #       expect(response_hash['token']).not_to eq(parse_response['token'])
  #     end
  #   end
  # end


end

RSpec.describe API::V1::RegistrationsController, type: :request do
  describe 'POST #signup' do
    let!(:account) { create(:account) }
    json_data = ENV['TENANTS_WORK_SETTINGS']
    if json_data.present? && json_data.class == String
      data = JSON.parse(json_data)
    end

    before do
      allow(AccountElevator).to receive(:switch!).with(account.cname)
      allow(AdminSet).to receive(:all).and_return([])
    end

    it 'creates a user when given the proper params' do
        post api_v1_user_signup_url(tenant_id: account.tenant), params: {
          email: "test.test#{data['email_format']}",
          password: 'Potato123!',
          password_confirmation: 'Potato123!'
        }
       parsed_response = JSON.parse(response.body)
      expect(parsed_response['email']).to eq("test.test#{data['email_format']}")
    end

    it 'returns an error if a user attempts to sign up with an already registered email' do
      2.times do
        post api_v1_user_signup_url(tenant_id: account.tenant), params: {
          email: "test.test#{data['email_format']}",
          password: 'Potato123!',
          password_confirmation: 'Potato123!'
        }
      end
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["message"]).to include("email" => ["has already been taken"])
    end

    it 'returns an error if using an email that is not of the correct format' do
      post api_v1_user_signup_url(tenant_id: account.tenant), params: {
        email: "test.test@test.com",
        password: 'Potato123!',
        password_confirmation: 'Potato123!'
      }
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["message"]).to include("email" => ["Email must contain #{data['email_format']}"])
    end

    it 'sends an email when a user signs up' do
      expect { post api_v1_user_signup_url(tenant_id: account.tenant), params: {
        email: "test.test#{data['email_format']}",
        password: 'Potato123!',
        password_confirmation: 'Potato123!'
      }}.to change{ Devise::Mailer.deliveries.count }.by(1)
    end
  end
end

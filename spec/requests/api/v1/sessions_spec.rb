require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::SessionsController, type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:account) { create(:account) }
  let(:admin_sets) { [] }

  before do
    WebMock.disable!
    allow(AdminSet).to receive(:all).and_return(admin_sets)
  end

  after do
    WebMock.enable!
  end

  describe "#login" do
    let(:email_credentials) { user.email }
    let(:password_credentials) { user.password }
    let(:json_response) { JSON.parse(response.body) }
    let(:jwt_cookie) { response.cookies.with_indifferent_access[:jwt] }

    context 'user is confirmed' do
      context 'with valid credentials' do
        it 'returns jwt token and json response' do
          post api_v1_user_login_url(tenant_id: account.id),  params: {
            email: email_credentials,
            password: password_credentials,
            expire: 2
          }
          expect(response.status).to eq(200)
          expect(json_response['email']).to eq(user.email)
          expect(json_response['participants']).to eq []
          expect(json_response['type']).to eq []
          expect(jwt_cookie).to be_truthy
        end

        context 'with type and participants' do
          let!(:user) { create(:admin, :confirmed) }
          let!(:admin_set) { create(:admin_set, with_permission_template: true) }
          let!(:permission_template_access) do
            create(:permission_template_access,
                   :manage,
                   permission_template: admin_set.permission_template,
                   agent_type: 'user',
                   agent_id: user.user_key)
          end
          let(:admin_sets) { [admin_set] }

          it 'returns jwt token and json response' do
            post api_v1_user_login_url(tenant_id: account.id),  params: {
              email: email_credentials,
              password: password_credentials,
              expire: 2
            }
            expect(response.status).to eq(200)
            expect(json_response['email']).to eq(user.email)
            expect(json_response['participants']).to eq [{admin_set.title.first => "manage"}]
            expect(json_response['type']).to eq ['admin']
            expect(jwt_cookie).to be_truthy
          end
        end
      end

      context 'with invalid credentials' do
        let(:password_credentials) { '' }

        it 'does not return jwt token' do
          post api_v1_user_login_url(tenant_id: account.id),  params: {
            email: email_credentials,
            password: password_credentials,
            expire: 2
          }
          expect(response.status).to eq(200)
          expect(json_response['status']).to eq(401)
          expect(json_response['message']).to eq("Invalid email or password.")
          expect(jwt_cookie).to be_falsey
        end
      end
    end

    context 'user is not confirmed' do
      let!(:user) { create(:user) }

      it 'does not return jwt token' do
        post api_v1_user_login_url(tenant_id: account.id),  params: {
          email: email_credentials,
          password: password_credentials,
          expire: 2
        }
        expect(response.status).to eq(200)
        expect(json_response['status']).to eq(401)
        expect(json_response['message']).to eq("Invalid email or password.")
        expect(jwt_cookie).to be_falsey
      end
    end
  end

  describe '#log_out' do
    before do
      post api_v1_user_login_url(tenant_id: account.id),  params: {
          email: user.email,
          password: user.password,
          expire: 2
        }
    end
    let(:json_response) { JSON.parse(response.body) }
    let(:jwt_cookie) { response.cookies.with_indifferent_access[:jwt] }

    it 'successfully logs out' do
      get api_v1_user_log_out_url(tenant_id: account.id)
      expect(response.status).to eq(200)
      expect(json_response['message']).to eq("Successfully logged out")
      expect(jwt_cookie).to be_falsey
    end
  end

  describe "#refresh" do
    context 'with an unexpired jwt token' do
      before do
        post api_v1_user_login_url(tenant_id: account.id),  params: {
            email: user.email,
            password: user.password,
            expire: 2
          }
      end
      let(:json_response) { JSON.parse(response.body) }
      let(:jwt_cookie) { response.cookies.with_indifferent_access[:jwt] }

      it "refreshs the jwt token" do
        expect { post api_v1_user_refresh_url(tenant_id: account.id), headers: { "Cookie" => response['Set-Cookie'] } }.to change { response.cookies.with_indifferent_access[:jwt] }
        expect(jwt_cookie).to be_truthy
      end

      it 'returns jwt token and json response' do
        post api_v1_user_refresh_url(tenant_id: account.id), headers: { "Cookie" => response['Set-Cookie'] }
        expect(response.status).to eq(200)
        expect(json_response['email']).to eq(user.email)
        expect(json_response['participants']).to eq []
        expect(json_response['type']).to eq []
        expect(jwt_cookie).to be_truthy
      end

      context 'with type and participants' do
        let!(:user) { create(:admin, :confirmed) }
        let!(:admin_set) { create(:admin_set, with_permission_template: true) }
        let!(:permission_template_access) do
          create(:permission_template_access,
                 :manage,
                 permission_template: admin_set.permission_template,
                 agent_type: 'user',
                 agent_id: user.user_key)
        end
        let(:admin_sets) { [admin_set] }

        it 'returns jwt token and json response' do
          post api_v1_user_refresh_url(tenant_id: account.id), headers: { "Cookie" => response['Set-Cookie'] }
          expect(response.status).to eq(200)
          expect(json_response['email']).to eq(user.email)
          expect(json_response['participants']).to eq [{admin_set.title.first => "manage"}]
          expect(json_response['type']).to eq ['admin']
          expect(jwt_cookie).to be_truthy
        end
      end

      context 'with an expired jwt token' do
        it 'returns an error' do
          travel_to(Time.now + 4.hours) do
            post api_v1_user_refresh_url(tenant_id: account.id), headers: { "Cookie" => response['Set-Cookie'] }
            expect(response.status).to eq(200)
            expect(json_response['status']).to eq(401)
            expect(json_response['message']).to eq("Invalid token")
            expect(jwt_cookie).to be_falsey
          end
        end
      end
    end
  end
end

require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::CollectionController, type: :request, clean: true do
  let!(:user) { create(:user, :confirmed) }
  let!(:account) { create(:account) }

  before do
    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  describe "/collection" do
    let(:json_response) { JSON.parse(response.body) }

    context 'when repository is empty' do
      it 'returns error' do
        get "/api/v1/tenant/#{account.id}/collection"
        expect(response.status).to eq(200)
        expect(json_response).to include('status' => 404,
                                         'code' => 'not_found',
                                         'message' => 'This tenant has no collection')
      end
    end

    context 'when repository has content' do
      let!(:collection) { create(:collection, visibility: 'open') }

      it 'returns collections' do
        get "/api/v1/tenant/#{account.id}/collection"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq collection.id
        expect(response).to render_template('api/v1/collection/_collection')
      end
    end

    context 'when not logged in' do
      let!(:collection) { create(:collection, visibility: 'restricted') }

      it 'does not return restricted items' do
        get "/api/v1/tenant/#{account.id}/collection"
        expect(response.status).to eq(200)
        expect(json_response).to include('total' => 0,
                                         'items' => [])
      end
    end

    context 'when logged in' do
      let!(:collection) { create(:collection, visibility: 'restricted') }
      let!(:user) { create(:admin, :confirmed) }

      before do
        post api_v1_user_login_url(tenant_id: account.id),  params: {
          email: user.email,
          password: user.password,
          expire: 2
        }
      end

      it 'returns restricted items' do
        get "/api/v1/tenant/#{account.id}/collection", headers: { "Cookie" => response['Set-Cookie'] }
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq collection.id
        expect(response).to render_template('api/v1/collection/_collection')
      end
    end

    context 'with per_page' do
      let!(:collection1) { create(:collection, visibility: 'open') }
      let!(:collection2) { create(:collection, visibility: 'open') }
      let(:per_page) { 1 }

      it 'limits the number of returned collections' do
        get "/api/v1/tenant/#{account.id}/collection?per_page=#{per_page}"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 2
        expect(json_response['items'].size).to eq 1
      end
    end
  end

  describe "/collection/:id" do
    let(:json_response) { JSON.parse(response.body) }

    context 'with invalid id' do
      let(:id) { 'bad-id' }

      it 'returns error' do
        get "/api/v1/tenant/#{account.id}/collection/#{id}"
        expect(response.status).to eq(200)
        expect(json_response).to include('status' => 404,
                                         'code' => 'not_found',
                                         'message' => "This is either a private collection or there is no record with id: #{id}")
      end
    end

    context 'with open collection' do
      let!(:collection) { create(:collection, visibility: 'open') }

      it 'returns collection json' do
        get "/api/v1/tenant/#{account.id}/collection/#{collection.id}"
        expect(response.status).to eq(200)
        expect(json_response['uuid']).to eq collection.id
        expect(response).to render_template('api/v1/collection/_collection.json.jbuilder')

        # TODO: Add more expectations about the shape of the exact data being returned
      end
    end

    context 'when not logged in' do
      let!(:collection) { create(:collection, visibility: 'restricted') }

      it 'does not return restricted collection' do
        get "/api/v1/tenant/#{account.id}/collection/#{collection.id}"
        expect(response.status).to eq(200)
        expect(json_response).to include('status' => 404,
                                         'code' => 'not_found',
                                         'message' => "This is either a private collection or there is no record with id: #{collection.id}")
      end
    end

    context 'when logged in' do
      let!(:collection) { create(:collection, visibility: 'restricted') }
      let!(:user) { create(:admin, :confirmed) }

      before do
        post api_v1_user_login_url(tenant_id: account.id),  params: {
          email: user.email,
          password: user.password,
          expire: 2
        }
      end

      it 'returns restricted items' do
        get "/api/v1/tenant/#{account.id}/collection/#{collection.id}", headers: { "Cookie" => response['Set-Cookie'] }
        expect(response.status).to eq(200)
        expect(json_response['uuid']).to eq collection.id
        expect(response).to render_template('api/v1/collection/_collection.json.jbuilder')
      end
    end
  end
end
require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::CollectionController, type: :request, clean: true do
  before do
    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  describe "/tenant" do
    let!(:account) { create(:account, name: 'test') }
    let(:json_response) { JSON.parse(response.body) }

    context 'with no params' do
      it 'returns no results' do
        get "/api/v1/tenant"
        expect(response.status).to eq(200)
        expect(json_response).to eq []
      end
    end

    context 'with name param' do
      it 'returns tenant json' do
        get "/api/v1/tenant?name=#{account.name}"
        expect(response.status).to eq(200)
        expect(json_response.size).to eq 1
        expect(json_response[0]).to include('id' => account.id)
        expect(response).to render_template('api/v1/tenant/_tenant')
      end
    end
  end

  describe "/tenant/:id" do
    let!(:account) { create(:account) }
    let(:json_response) { JSON.parse(response.body) }

    it 'returns tenant json' do
      get "/api/v1/tenant/#{account.tenant}"
      expect(response.status).to eq(200)
      expect(json_response).to include('id' => account.id,
                                       'tenant' => account.tenant,
                                       'cname' => account.cname,
                                       'solr_endpoint' => account.solr_endpoint_id,
                                       'fcrepo_endpoint' => account.fcrepo_endpoint_id,
                                       'name' => account.name,
                                       'redis_endpoint' => account.redis_endpoint_id,
                                       'parent' => account.parent_id,
                                       'settings' => be_a(Hash),
                                       'data' => {},
                                       'site' => { "id" => 1,
                                                   "application_name" => nil,
                                                   "created_at" => be_a(String),
                                                   "updated_at" => be_a(String),
                                                   "account_id" => be_a(Integer), # not equal to account.id?
                                                   "institution_name" => nil,
                                                   "institution_name_full" => nil,
                                                   "banner_image" => nil,
                                                   'banner_images' => { 'url' => be_a(String) }},
                                       'content_block' => [],
                                       'google_tag_manager_id' => nil)
    end

    context 'when given a bad tenant id' do
      it 'returns error' do
        get "/api/v1/tenant/bad-id"
        expect(response.status).to eq(200)
        expect(json_response['error']).to include('status' => "400",
                                                  'code' => 'not_found',
                                                  'message' => "Couldn't find Account with 'tenant uuid'=bad-id")
      end
    end
  end
end
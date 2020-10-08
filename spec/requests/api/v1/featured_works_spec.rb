require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::FeaturedWorksController, type: :request, clean: true do
  let!(:account) { create(:account) }
  let!(:work) { create(:work, visibility: 'open' ) }
  let(:json_response) { JSON.parse(response.body) }

  describe "POST /featured_works" do
    it 'features a work' do
      expect do
        post "/api/v1/tenant/#{account.id}/work/#{work.id}/featured_works", params: { order: 1 }
      end.to change { FeaturedWork.count }.by(1)
      expect(response.status).to eq(200)
      expect(json_response['code']).to eq(201)
      expect(json_response['status']).to eq 'created'
    end

    context 'when required parameter is missing' do
      it 'does not feature the work' do
        expect do
          post "/api/v1/tenant/#{account.id}/work/#{work.id}/featured_works", params: {}
        end.not_to change { FeaturedWork.count }
        expect(response.status).to eq(422)
        expect(json_response).to eq({ "order" => ["is not included in the list"] })
      end
    end
  end

  describe "DELETE /featured_works" do
    before do
      FeaturedWork.create(work_id: work.id, order: 1)
    end

    it 'removes feature of a work' do
      expect do
        delete "/api/v1/tenant/#{account.id}/work/#{work.id}/featured_works"
      end.to change { FeaturedWork.count }.by(-1)
      expect(response.status).to eq(204)
      expect(response.body).to be_blank
    end
  end
end
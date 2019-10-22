require 'rails_helper'

RSpec.describe AvailableUbiquityTitlesController, type: :controller do
  include DataCiteCrossrefClientHelpers

  let (:json_data) {File.read(Rails.root.join("spec/fixtures/json/datacite_v2.json")) }
  let (:url) { 'https://dx.doi.org/10.15123%2FPUB.7627' }
  let (:datacite_client_1)  {Ubiquity::DataciteClient.new(url)}
  let (:crossref_client_1)  {Ubiquity::DataciteClient.new(url)}

  describe "GET #call_datasite" do
    before do
      stub_request_datacite_client1(datacite_client_1, json_data)
      stub_request_crossref_client1(crossref_client_1, json_data)
      post :call_datasite, params: {:url => url}
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns a 200 status" do
      expect(response.status).to eq 200
    end

    it "JSON body response contains expected attributes" do
      json_response = JSON.parse(response.body)["data"]
      keys_collection = ["abstract", "contributor_group", "creator_group", "doi", "funder", "license", "official_url", "published_year", "publisher", "related_identifier_group", "title", "version"]
      expect(json_response.keys).to match_array(keys_collection)
    end

  end
end

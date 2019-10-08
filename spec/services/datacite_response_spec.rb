RSpec.describe Ubiquity::DataciteResponse do
  include DataCiteCrossrefClientHelpers

  let (:json_data) {File.read(Rails.root.join("spec/fixtures/json/datacite2.json")) }
  let (:full_datacite_url) { 'https://dx.doi.org/10.15123%2FPUB.7627' }
  let (:datacite_client_1)  {Ubiquity::DataciteClient.new(full_datacite_url)}
  let (:crossref_client_1)  {Ubiquity::DataciteClient.new(full_datacite_url)}

  before(:each) do
    stub_request_datacite_client1(datacite_client_1, json_data)
    stub_request_crossref_client1(crossref_client_1, json_data)
    result = datacite_client_1.fetch_record
    @response_hash = result.api_response
    @response_object = described_class.new(response_hash: @response_hash, result: result)
    @data_hash = @response_object.api_response["data"]["attributes"]
    @json_object = JSON.parse(json_data)
  end

context 'check values in response hash' do
    describe '#title' do
      it 'returns the property title' do
         title_from_json_data =  @json_object["data"]["attributes"]["title"]
         title_from_response = @data_hash["title"]
         expect(title_from_response).to eq title_from_json_data
      end
    end

    describe '#date_published_year' do
      it 'returns the property date_published_year' do
         year_from_response = @response_object.date_published_year
         year_from_json_data =  @json_object["data"]["attributes"]["published"]
         expect(year_from_response).to eq year_from_json_data
      end
    end

    describe '#abstract' do
      it 'returns the property description/abstract' do
         description_from_response = @data_hash["description"]
         description_from_json_data =  @json_object["data"]["attributes"]["description"]
         expect(description_from_response).to eq description_from_json_data
      end
    end

    describe '#version' do
      it 'returns the property version' do
         version_from_response = @response_object.version
         version_from_json_data =  @json_object["data"]["attributes"].dig('version')
         expect(version_from_response).to eq version_from_json_data
      end
    end

    describe '#doi' do
      it 'returns the property doi identifier' do
         doi_from_response = @response_object.doi["doi"]
         doi_from_json_data =  @json_object["data"]["attributes"].dig('identifier')
         expect(doi_from_response).to eq doi_from_json_data
      end
    end

    describe '#funder' do
      it 'returns the property funder' do
         funder_from_response = @response_object.funder
         funder_from_json_data = nil if @json_object["data"]["attributes"].dig('fundingReferences') == []
         expect(funder_from_response).to eq nil
      end
    end

    describe '#official_url' do
      it 'returns the property official_url' do
         official_url_from_response = @response_object.official_url
         official_url_from_json_data = @json_object["data"]["attributes"]["identifiers"][0]["identifier"]
         expect(official_url_from_response).to eq official_url_from_json_data
      end
    end

    describe '#publisher' do
      it 'returns the property publisher' do
         official_url_from_response = @response_object.publisher
         official_url_from_json_data = @json_object["data"]["attributes"]["publisher"]
         expect(official_url_from_response).to eq official_url_from_json_data
      end
    end

    describe '#creator' do
      it 'returns the property creator' do
         creator_name_from_response = @response_object.creator[0]["creator_given_name"]
         creator_name_from_json_data =  @json_object["data"]["attributes"].dig('creators')[0]['givenName']
         creator_family_name_from_response = @response_object.creator[0]["creator_family_name"]
         creator_family_name_from_json_data =  @json_object["data"]["attributes"].dig('creators')[0]['familyName']
         expect(creator_name_from_response).to eq creator_name_from_json_data
         expect(creator_family_name_from_response).to eq creator_family_name_from_json_data
      end
    end

    describe '#license' do
      it 'returns the property license' do
         license_from_response = @response_object.license[:license]
         if license_from_response.present?
           license_from_json_data = @json_object["data"]["attributes"]["rightsList"].last["rightsUri"]
         else
           license_from_json_data = nil
         end
         expect(license_from_response).to eq license_from_json_data
      end
    end

    describe '#related_identifier' do
      it 'returns the property related_identifier' do
        identifier_from_response = @response_object.related_identifier
        identifier_from_json_data = nil if @json_object["data"]["attributes"]['relatedIdentifiers'] == []
        expect(identifier_from_response).to eq identifier_from_json_data
      end
    end

    describe '#Instance of DataciteResponse' do
      it 'returns an instance of  DataciteResponse' do
        expect(@response_object).to be_an_instance_of(Ubiquity::DataciteResponse)
      end
    end

  end
end

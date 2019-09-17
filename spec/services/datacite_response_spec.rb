RSpec.describe Ubiquity::DataciteResponse do
  include DataCiteCrossrefClientHelpers

  let (:json_data) {File.read(Rails.root.join("spec/fixtures/json/datacite.json")) }
  let (:full_datacite_url) { 'https://dx.doi.org/10.15123%2FPUB.7627' }
  let (:datacite_client_1)  {Ubiquity::DataciteClient.new(full_datacite_url)}

  before(:each) do
    stub_request_datacite_client1(datacite_client_1, json_data)
    result = datacite_client_1.fetch_record_from_datacite
    response_hash = result.parsed_response
    @response_object  = described_class.new(response_hash: response_hash, result: result)
    @json_object = JSON.parse(json_data)
  end

context 'check values in response hash' do
    describe '#title' do
      it 'returns the property title' do
         title_from_response = @response_object.title
         title_from_json_data =  @json_object["data"]["attributes"]["title"]
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

    describe '#description' do
      it 'returns the property description/abstract' do
         description_from_response = @response_object.abstract
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
         doi_from_response = @response_object.doi
         doi_from_json_data =  @json_object["data"]["attributes"].dig('identifier')
         expect(doi_from_response).to eq doi_from_json_data
      end
    end

    describe '#creator' do
      it 'returns the property creator' do
         creator_name_from_response = @response_object.creator[0]['creator_given_name']
         creator_name_from_json_data =  @json_object["data"]["attributes"].dig('author')[0]['given']
         creator_family_name_from_response = @response_object.creator[0]['creator_family_name']
         creator_family_name_from_json_data =  @json_object["data"]["attributes"].dig('author')[0]['family']
         expect(creator_name_from_response).to eq creator_name_from_json_data
         expect(creator_family_name_from_response).to eq creator_family_name_from_json_data
      end
    end

    describe '#license' do
      it 'returns the property license' do
         license_from_response = @response_object.license
         if license_from_response.present?
           license_from_json_data = @json_object["data"]["attributes"].dig('license')
         else
           license_from_json_data = nil
         end
         expect(license_from_response).to eq license_from_json_data
      end
    end

    describe '#related_identifier' do
      it 'returns the property related_identifier' do
        identifier_from_response = @response_object.related_identifier
        identifier_from_json_data = @json_object["data"]["attributes"]['related-identifiers']
        expect(identifier_from_response).to eq identifier_from_json_data
      end
    end

    describe '#Instance of DataciteResponse' do
      it 'returns an instance of  DataciteResponse' do
        data_from_response = @response_object.data
        expect(@response_object).to be_an_instance_of(Ubiquity::DataciteResponse)
      end
    end

    describe '#data' do
      it 'returns the data with the correct keys' do
        data_from_response = @response_object.data
        expect(data_from_response).to have_key(:title)
        expect(data_from_response).to have_key(:related_identifier_group)
        expect(data_from_response).to have_key(:abstract)
        expect(data_from_response).to have_key(:version)
        expect(data_from_response).to have_key(:creator_group)
        expect(data_from_response).to have_key(:license)
        expect(data_from_response).to have_key(:doi)
        expect(data_from_response).to have_key(:published_year)
      end
    end

  end
end

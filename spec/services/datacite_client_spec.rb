RSpec.describe Ubiquity::DataciteClient do
  include DataCiteCrossrefClientHelpers

  let (:json_data) {File.read(Rails.root.join("spec/fixtures/json/datacite_v1.json")) }
  let (:full_datacite_url) { 'https://dx.doi.org/10.15123%2FPUB.7627' }
  let (:partial_datacite_url) { '10.15123%2FPUB.7627' }
  let (:datacite_client_1)  {described_class.new(full_datacite_url)}
  let (:datacite_client_2)  {described_class.new(partial_datacite_url)}

  context 'initialize datacite client with an HTTP GET to /api.datacite.org' do
    #fetch_record_from_datacite
    describe '#path' do
      it 'returns a path ' do
        stub_request_datacite_client1(datacite_client_1, json_data)
        expect(datacite_client_1.path).to eq "/10.15123/PUB.7627"
      end
    end
  end

  context 'fetch_record_from_datacite' do
    describe '#fetch_record with full url' do
      it 'returns a  HTTParty::Response' do
        stub_request_datacite_client1(datacite_client_1, json_data)
        response_object =  datacite_client_1.fetch_record_from_datacite
        fetch_record_expectations(response_object, json_data)
      end
    end

     describe '#fetch_record with url path' do
        it 'returns a  HTTParty::Response' do
          stub_request_datacite_client2(datacite_client_2, json_data)
          response_object =  datacite_client_2.fetch_record_from_datacite
          fetch_record_expectations(response_object, json_data)
        end
      end
  end

  private

  def fetch_record_expectations(response_object, json_record)
    expect(response_object.class).to eq HTTParty::Response
    expect(response_object.success?).to eq true
    expect(response_object.headers['content-type']).to eq "application/json; charset=utf-8"
    expect(response_object.parsed_response).to eq JSON.parse(json_record)
  end
end

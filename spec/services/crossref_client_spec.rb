RSpec.describe Ubiquity::DataciteClient do
  include DataCiteCrossrefClientHelpers
  
  let (:json_data) {File.read(Rails.root.join("spec/fixtures/json/crossref.json")) }
  let (:full_crossref_url) { 'http://dx.doi.org/10.1007%2Fs13197-019-03605-z' }
  let (:partial_crossref_url) { '10.1007%2Fs13197-019-03605-z' }
  let (:crossref_client_1)  {described_class.new(full_crossref_url)}
  let (:crossref_client_2)  {described_class.new(partial_crossref_url)}

  context 'initialize crossref client with an HTTP GET to /api.crossref.org' do
    #fetch_record_from_crossref
    describe '#path' do
      it 'returns a path ' do
        stub_request_crossref_client1(crossref_client_1, json_data)
        expect(crossref_client_1.path).to eq "/works/10.1007/s13197-019-03605-z"
      end
    end
  end

  context 'fetch_record_from_crossref' do
    describe '#fetch_record with full url' do
      it 'returns a  HTTParty::Response' do
        stub_request_crossref_client1(crossref_client_1, json_data)
        response_object =  crossref_client_1.fetch_record_from_crossref
        fetch_record_expectations(response_object, json_data)
      end
    end

     describe '#fetch_record with url path' do
        it 'returns a  HTTParty::Response' do
          stub_request_crossref_client2(crossref_client_2, json_data)
          response_object =  crossref_client_2.fetch_record_from_crossref
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

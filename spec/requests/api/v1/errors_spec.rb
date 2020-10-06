require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::ErrorsController, type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "/errors" do
    it 'echos back the error as JSON' do
      get api_v1_errors_url, params: { errors: "Test Error" }
      expect(response.status).to eq(200)
      expect(json_response[0]['errors']).to eq "Test Error"
    end
  end
end
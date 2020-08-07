module Ubiquity
  class FunderApiData
    attr_accessor :response

    def initialize(funder_id)
      url = 'https://api.ror.org/organizations?query=' + funder_id
      @response = fetch_record_from_url(url)
    end

    def fetch_isni
      response_hash = response.parsed_response
      response_hash.dig('items').first['external_ids'].dig('ISNI')['all']
    end

    def fetch_ror
      response_hash = response.parsed_response
      response_hash.dig('items').first['external_ids'].dig('GRID')['all']
    end

    private

    def fetch_record_from_url(url)
      handle_client do
        HTTParty.get(url)
      end
    end

    def handle_client
      begin
        yield
      rescue  URI::InvalidURIError, HTTParty::Error, Net::HTTPNotFound, NoMethodError, Net::OpenTimeout, StandardError => e
        puts "Api server error #{e.inspect}"
      end
    end
  end
end
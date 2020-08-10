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

    def fetch_awards
      response_hash = response.parsed_response
      response_hash.dig('items').first['external_ids'].dig('FundRef')['all']
    end

    def fetch_ror
      response_hash = response.parsed_response
      response_hash.dig('items').first.dig('id')
    end

    def fetch_record
      if response.class == HTTParty::Response && response_hash.dig('items').first
        { 'funder_isni' => fetch_isni,
          'funder_awards' => fetch_awards,
          'funder_ror' => fetch_ror
        }
      else
        { error: response }
      end
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
        "Api server error #{e.inspect}"
      end
    end
  end
end
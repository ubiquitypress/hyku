module Ubiquity
  class IndexerClient
    include HTTParty
    base_uri "http://indexer.ubiquity.press"
    attr_reader :api_path, :headers, :resource_type, :work_uuid

    def initialize(uuid)
      @resource_type = "repository_work"
      @work_uuid = uuid
    end

    def post
      body = {resource_type: resource_type, uuid: work_uuid}.to_json
      handle_client do
        self.class.post(api_path, body: body, headers: headers )
      end
    end

    private

    def api_path
      '/api/entry/'
    end

    def handle_client
      begin
        yield
      rescue HTTParty::Error => e
        puts "Nothing pushed to indexer"
      end
    end

    def headers
      {
         'Content-Type' => 'application/json',
         'Authorization' => "Token #{ENV['INDEXER_API_TOKEN']}"
        }

    end

  end
end

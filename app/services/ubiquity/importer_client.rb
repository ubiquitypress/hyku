module Ubiquity
  class ImporterClient
    # Api call wrapper class for setting up the s3 url to each file set records
    # Called in show page and the file details page of the evert works created by user
    include HTTParty
    format :json
    base_uri ENV['S3_API_WRAPPER_URL']

    attr_accessor :file_url_hash, :file_status_hash

    def initialize(response = nil)
      if response
        @file_status_hash = Hash[response.parsed_response['uuid'], response.parsed_response['status']]
        @file_url_hash = Hash[response.parsed_response['uuid'], response.parsed_response['providers'].try(:fetch, 'S3Storage', '').try(:fetch, 'link')]
      else
        @file_status_hash = {}
        @file_url_hash = {}
      end
    end

    def self.get_s3_url(uuid)
      response = get("/api/file/#{uuid}", base_uri: base_uri)
      if response.success?
        new(response)
      else
        new(nil)
      end
    end

    def post_to_importer(fileset_uuid, tenant_uuid)
      body = {fileset_uuid: fileset_uuid, tenant_uuid: tenant_uuid}.to_json
      handle_client do
        response = self.class.post("/api/file/", body: body)
      end
    end

    private

    def handle_client
      begin
        yield
      rescue HTTParty::Error, Errno::ECONNREFUSED, SocketError, Timeout::Error  => e
        puts "Nothing posted to importer #{e.inspect}"
      end
    end

  end
end

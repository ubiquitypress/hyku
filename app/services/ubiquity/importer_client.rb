module Ubiquity
  class ImporterClient
    # Api call wrapper class for setting up the s3 url to each file set records
    # Called in show page and the file details page of the evert works created by user
    include HTTParty
    format :json
    base_uri 'https://importer.repo-test.ubiquity.press'

    attr_accessor :file_url_hash, :file_name_hash

    def initialize(response)
      if response
        @file_name_hash = Hash[response['works'].map { |ele| [ele['uuid'], ele['name']] }]
        @file_url_hash = Hash[response['works'].map { |ele| [ele['uuid'], ele['providers']['S3Storage']['link']] }]
      else
        @file_name_hash = {}
        @file_url_hash = {}
      end
    end

    def self.get_s3_url(uuid)
      response = get("/api/entry/#{uuid}", base_uri: base_uri)
      if response.success?
        new(response)
      else
        new(nil)
      end
    end
  end
end

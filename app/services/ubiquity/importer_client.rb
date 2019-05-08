module Ubiquity
  class ImporterClient
    # Api call wrapper class for setting up the s3 url to each file set records
    # Called in show page and the file details page of the evert works created by user
    include HTTParty
    format :json
    base_uri 'https://importer.repo-test.ubiquity.press'

    attr_accessor :file_url_hash, :file_status_hash

    def initialize(response)
      if response
        @file_status_hash = Hash[response['works'].map { |ele| [ele['uuid'], ele['status']] }]
        @file_url_hash = Hash[response['works'].map { |ele| [ele['uuid'], ele['providers'].try(:fetch, 'S3Storage', '').try(:fetch, 'link')] }]
      else
        @file_status_hash = {}
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

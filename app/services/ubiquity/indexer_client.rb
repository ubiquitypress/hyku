module Ubiquity
  class IndexerClient
    include HTTParty
    base_uri "http://indexer.ubiquity.press"
    attr_reader :api_path, :headers, :resource_type, :work_uuid, :draft_doi

    def initialize(uuid, draft_doi)
      @resource_type = "repository_work"
      @work_uuid = uuid
      @draft_doi = draft_doi
    end

    def post
      body = {resource_type: resource_type, uuid: work_uuid}.to_json
      handle_client do
        response = self.class.post(api_path, body: body, headers: headers )
        external_service = ExternalService.where(draft_doi: draft_doi).first
        external_service.try(:data)['status_code'] = response.code
        external_service.save
        set_official_url(work_uuid, response.code)
        response
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
        puts "Nothing pushed to indexer #{e.inspect}"
      end
    end

    def headers
      {
         'Content-Type' => 'application/json',
         'Authorization' => "Token #{ENV['INDEXER_API_TOKEN']}"
        }

    end

    def set_official_url(id, status_code)
      work = ActiveFedora::Base.find(id)
      if [201, 200].include? status_code
        work.update(official_link: "https://doi.org/#{work.draft_doi}")
      end
    end


  end
end

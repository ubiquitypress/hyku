module Ubiquity
  class DoiService
    attr_reader :tenant_name, :datacite_prefix
    MAX_RETRIES = 3

    def initialize(params, datacite_prefix)
      @tenant_name = params['tenant_name']
      @datacite_prefix = datacite_prefix
    end

    def suffix_generator
      AccountElevator.switch!(tenant_name)
      #fetches external service object and get latest suffix
      old_suffix = latest_suffix_from_external_service_object
      work_with_draft_doi = query_work_for_draft_doi(old_suffix)
      if work_with_draft_doi.blank? &&  @external_service_object.present?
        puts "Using the latest un-assigned doi"
        #picking up the latest un-assigned doi
        external_service_record = @external_service_object
      else
        puts "Creating a new doi"
        #create or mint new doi
        incremented_number = old_suffix.to_i + 1
        full_doi = "#{datacite_prefix}/#{incremented_number}"
        external_service_record = ExternalService.create!(draft_doi: full_doi, api_type: 'datacite_indexer')
      end
     # value returned to the controller
      external_service_record

      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      puts "ExternalService creation failed with  #{e.inspect}"
      @failed_attempts = nil
      @failed_attempts = @failed_attempts.to_i + 1
      retry if @failed_attempts < MAX_RETRIES
    end

    private
      def latest_suffix_from_external_service_object
        last_record = fetch_last_record
        puts"Fetching last record #{last_record}"
        if last_record.class == ExternalService
          #last_record.draft_doi.split('/').last.to_i
          get_doi_suffix(last_record.draft_doi)
        else
          last_record || 0
        end
      end

      def fetch_last_record
        AccountElevator.switch!(tenant_name)
        @external_service_object ||= ExternalService.where("draft_doi IS NOT NULL").last
      end

      def get_doi_suffix(doi_number)
        doi_number.split('/').last.to_i
      end

      def query_work_for_draft_doi(suffix)
        puts"Inside query for draft_doi"
        ActiveFedora::Base.where("draft_doi_tesim:#{suffix}").last
      end

      def fetch_tenant_url
        if @tenant_name.present?
          if @tenant_name.split('.').include? 'localhost'
            "http://#{@tenant_name}:3000"
          else
            "https://#{@tenant_name}"
          end
        end
      end
  end
end

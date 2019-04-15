module Ubiquity
  class DoiService
    attr_reader :tenant_name, :tenant_id
    MAX_RETRIES = 3

    def initialize(tenant_name, tenant_id)
      @tenant_name = tenant_name
      @tenant_id = tenant_id
    end

    def suffix_generator
      old_suffix = latest_suffix

      #increment the slit record
      incremented_number = old_suffix + 1
      full_doi = "#{ENV["datacite_prefix"]}/#{incremented_number}"

      #create or mint new doi
      Ubiquity::ExternalService.create!(draft_doi: full_doi, account_id: tenant_id )

      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
         @failed_attempts = nil
         @failed_attempts = @failed_attempts.to_i + 1
      retry if @failed_attempts < MAX_RETRIES
    end

    def latest_suffix
      last_record = fetch_last_record
      last_record.draft_doi.split('/').last.to_i
    end

    def fetch_last_record
      AccountElevator.switch!(tenant_name)
      Ubiquity::ExternalService.order("draft_doi desc").first
    end

  end
end

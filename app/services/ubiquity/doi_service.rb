module Ubiquity
  class DoiService
    attr_reader :tenant_name, :datacite_prefix
    MAX_RETRIES = 3

    def initialize(tenant_name, datacite_prefix)
      @tenant_name = tenant_name
      @datacite_prefix = datacite_prefix
    end

    def suffix_generator
      old_suffix = latest_suffix

      #increment the split record
      incremented_number = old_suffix.to_i + 1
      full_doi = "#{datacite_prefix}/#{incremented_number}"

      #create or mint new doi
      AccountElevator.switch!(tenant_name)
      ExternalService.create!(draft_doi: full_doi)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
        puts"I AM HEREE #{e.inspect}"
         @failed_attempts = nil
         @failed_attempts = @failed_attempts.to_i + 1
        retry if @failed_attempts < MAX_RETRIES
      end

    private
    def latest_suffix
      last_record = fetch_last_record
      if last_record.class == ExternalService
        last_record.draft_doi.split('/').last.to_i
      else
        last_record
      end
    end

    def fetch_last_record
      AccountElevator.switch!(tenant_name)
      ExternalService.last || 0
    end

  end
end

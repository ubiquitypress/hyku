module Ubiquity
  module WorkDoiLifecycle
    extend ActiveSupport::Concern

    included do
      attr_accessor :previous_work_visibility
      after_save :post_to_indexer_if_doi_work_visibility_changed
    end


    private

    def post_to_indexer_if_doi_work_visibility_changed
      AccountElevator.switch!(self.account_cname)
      if doi_enabled? && self.visibility == 'open' && self.draft_doi && (self.doi_options == 'Mint DOI:Registered' || self.doi_options == 'Mint DOI:Findable')
        puts "Post to indexer #{self.id}"
        #UbiquityPostToIndexerJob.perform_later(self.id, self.draft_doi, self.account_cname)
        Ubiquity::IndexerClient.new(self.id, self.draft_doi, self.account_cname).post

      end
    end

    def doi_enabled?
      tenant_name = self.account_cname.split('.').first
      tenant_json = ENV["TENANTS_SETTINGS"]
      tenant_hash = JSON.parse(tenant_json) if is_valid_json?(tenant_json)
      feature_hash = JSON.parse(ENV['FEATURE_ENABLED']) if is_valid_json?(ENV['FEATURE_ENABLED'])
      if tenant_hash.present? && feature_hash.present? && tenant_hash[tenant_name]['datacite_prefix'].present?
        (feature_hash['doi_option'] == 'true') && (tenant_hash[tenant_name]['ENABLE_DOI'] == "true")
      end
    end

    def is_valid_json?(data)
      !!JSON.parse(data)  if data.class == String
      rescue JSON::ParserError
        false
    end
  end
end

module Ubiquity
  module WorkDoiLifecycle
    extend ActiveSupport::Concern

    attr_accessor :previous_work_visibility
    included do
      after_save :post_to_indexer_if_doi_work_visibility_changed
    end



    private

    def post_to_indexer_if_doi_work_visibility_changed
      AccountElevator.switch!(self.account_cname)
      external_service = ExternalService.where(draft_doi: self.draft_doi).first
      status_code = external_service.data['status_code'] if external_service.present?
      #called for new record and updating of old record where visibility_changed is true
      if  status_code != '201' && self.visibility == 'open' && (self.doi_options == 'Mint DOI:Registered' || self.doi_options == 'Mint DOI:Findable')
        puts "Post to indexer #{self.id}"
        UbiquityPostToIndexerJob.perform_later(self.id, self.draft_doi)
      end
    end

    def check_field_changes
      self.visibility_changed? == true || self.doi_options_changed? == true
    end

  end
end

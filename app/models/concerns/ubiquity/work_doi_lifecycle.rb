module Ubiquity
  module WorkDoiLifecycle
    extend ActiveSupport::Concern

    attr_accessor :previous_work_visibility
    included do
      after_save :post_to_indexer_if_doi_work_visibility_changed
    end



    private

    def post_to_indexer_if_doi_work_visibility_changed
      #called for new record and updating of old record where visibility_changed is true
      if self.visibility_changed? == true  && self.visibility == 'open' && (self.doi_options == 'Mint DOI:Registered' || self.doi_options == 'Mint DOI:Findable')
        puts "Post to indexer #{self.id}"
        UbiquityPostToIndexerJob.perform_later(self.id)
      elsif self.doi.present? && self.visibility == 'open'
        puts "Push to indexer #{self.id}"
      end
    end

    def check_field_changes
      self.visibility_changed? == true || self.doi_options_changed? == true
    end

  end
end

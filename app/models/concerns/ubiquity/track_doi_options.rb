
module Ubiquity
  module TrackDoiOptions
    extend ActiveSupport::Concern

    included do
      #after_save :set_disable_draft_doi
      #after_save :set_doi
    end

    private

    def set_disable_draft_doi
      #if  old_value == "Keep DOI as Draft"  && new_value ==  "Do not mint DOI"
      if self.doi_options != "Do not mint DOI"
        self.disable_draft_doi = 'true'
      end
    end

    def set_doi
      puts"self doi options = #{self.doi_options.inspect}"
      puts"visibility = #{self.visibility.inspect}"
      if (self.doi_options == 'Mint DOI:Registered' || self.doi_options == 'Mint DOI:Findable') && self.visibility == 'open'
        self.doi = self.draft_doi
      end
    end

  end
end

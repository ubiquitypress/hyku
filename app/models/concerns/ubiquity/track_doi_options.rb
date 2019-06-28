
module Ubiquity
  module TrackDoiOptions
    extend ActiveSupport::Concern

    included do
      before_save :set_disable_draft_doi
      before_save :autocreate_draft_doi
      before_save :set_doi
      before_save :set_manual_doi
    end

    def set_manual_doi
      if self.doi.present?
        puts"MADAGASCAR"
        clean_doi
      end
    end

    private

    def clean_doi
      puts"CANCUN"
    #  new_doi = URI(self.doi.strip)
      new_doi = Addressable::URI.parse(self.doi.strip)
      new_doi_path = prepend_protocol.try(:path)
      if new_doi_path.slice(0) == "/"
        puts"NAPOLI"
        new_doi_path.slice!(0)
        self.doi = new_doi_path
      else
        puts"ROME"
        self.doi = new_doi_path
      end
    end

    def prepend_protocol
      puts"MADRID"
     doi = Addressable::URI.parse(self.doi.strip)
     doi_path = doi.path
     if doi.scheme  == nil
       puts"SPAIN"
       new_doi = doi_path.split('/').count < 3 ? doi_path : 'https://' + doi_path
       full_doi = Addressable::URI.parse(new_doi)
     else
       puts"LONDON"
       doi
     end
    end

    def set_disable_draft_doi
      if self.doi_options == "Do not mint DOI"
        self.disable_draft_doi = 'true'
      else
        self.disable_draft_doi = 'false'
      end
    end

    def set_doi
      if (self.doi_options == 'Mint DOI:Registered' || self.doi_options == 'Mint DOI:Findable') && self.visibility == 'open'
        self.doi = self.draft_doi
      end
    end

    def autocreate_draft_doi
      if self.doi_options != "Do not mint DOI" && self.draft_doi.blank?
        tenant_name = self.account_cname.split('.').first
        tenant_json = ENV["TENANTS_SETTINGS"]
        tenant_hash = JSON.parse(tenant_json) if is_valid_json?(tenant_json)
        datacite_prefix = tenant_hash.dig(tenant_name, 'datacite_prefix')
        if datacite_prefix.present?
          doi_service = Ubiquity::DoiService.new(self.account_cname, datacite_prefix)
          external_service_object = doi_service.suffix_generator
          self.draft_doi = external_service_object.draft_doi
        end
      end
    end

    def is_valid_json?(data)
      !!JSON.parse(data)  if data.class == String
      rescue JSON::ParserError
        false
    end


  end
end

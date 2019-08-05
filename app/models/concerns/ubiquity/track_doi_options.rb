
module Ubiquity
  module TrackDoiOptions
    extend ActiveSupport::Concern

    included do
      before_save :autocreate_draft_doi
      before_save :set_doi
      before_save :set_manual_doi
      before_save :set_disable_draft_doi
    end

    def set_manual_doi
      if self.doi.present?
        clean_doi
      end
    end

    private

      def clean_doi
        refined_url = remove_unwanted_characters_from_doi
        doi_path = Addressable::URI.parse(refined_url).path
        self.doi = doi_path
      end

      def remove_unwanted_characters_from_doi
        url_ary = self.doi.strip.split('/')
        url_ary.shift(2) if ['https', 'https:', 'http', 'http:'].include?(url_ary.first)
        url_ary.join('/')
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
          tenant_name = self.account_cname.split('.').first if self.account_cname.present?
          tenant_json = ENV["TENANTS_SETTINGS"]
          tenant_hash = JSON.parse(tenant_json) if is_valid_json?(tenant_json)
          datacite_prefix = tenant_hash.dig(tenant_name, 'datacite_prefix') if tenant_name.present?
          if datacite_prefix.present?
            doi_service = Ubiquity::DoiService.new({'tenant_name' => self.account_cname}, datacite_prefix)
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

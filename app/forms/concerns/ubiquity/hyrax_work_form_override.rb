module Ubiquity
  module HyraxWorkFormOverride
    extend ActiveSupport::Concern
    included do
      delegate :account_cname, :collection_id, :collection_names, to: :model
      class_attribute :remove_required_from_primary
      self.remove_required_from_primary = []
    end

    def not_needed_fields
          parser_class = Ubiquity::ParseTenantWorkSettings.new(account_cname)
          unwanted_fields_hash = parser_class.check_for_setting('work_unwanted_fields')
          selected_work = self.class.to_s.gsub("Hyrax::", '').gsub('Form', '').underscore
          if unwanted_fields_hash.present? && unwanted_fields_hash.keys.include?(selected_work)
            array_of_fields = unwanted_fields_hash[selected_work].split(',')
            array_of_fields.map{|ele| ele.to_sym}
          end
        end

    def primary_terms
       terms - [:collection_id, :collection_names]
        required_fields - remove_required_from_primary
    end

    def secondary_terms
      if not_needed_fields.present?
       terms - not_needed_fields - primary_terms -
         [:files, :visibility_during_embargo, :embargo_release_date,
          :visibility_after_embargo, :visibility_during_lease,
          :lease_expiration_date, :visibility_after_lease, :visibility,
          :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
          :member_of_collection_ids, :in_works_ids, :admin_set_id,
          :collection_id, :collection_names
          ]
      else
        terms - primary_terms -
          [:files, :visibility_during_embargo, :embargo_release_date,
           :visibility_after_embargo, :visibility_during_lease,
           :lease_expiration_date, :visibility_after_lease, :visibility,
           :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
           :member_of_collection_ids, :in_works_ids, :admin_set_id,
           :collection_id, :collection_names
         ]
      end
    end

    def public_collections_for_select
      service = Hyrax::CollectionsService.new(@controller)
      Hyrax::CollectionOptionsPresenter.new(service).select_options(:read)
    end

    # Select collection(s) based on passed-in params and existing memberships.
    # @return [Array] a list of collection identifiers
    def non_fedora_association_collection_id(collection_ids)
      #@collection_is = collection_id || []
      (collection_id + Array.wrap(collection_ids)).uniq.compact
    end
  end
end

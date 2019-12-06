module Ubiquity
  module HyraxWorkFormOverride
    extend ActiveSupport::Concern
    included do
      delegate :account_cname, to: :model
      class_attribute :remove_required_from_primary
      self.remove_required_from_primary = []
    end

    def not_needed_fields
      json_data = ENV['TENANTS_WORK_SETTINGS']
      settings_hash = JSON.parse(json_data)
      host_name = account_cname.split('.').first
      host_hash = settings_hash[host_name]
      unwanted_fields_hash = host_hash.presence && host_hash['work_unwanted_fields']
      selected_work = self.class.to_s.gsub("Hyrax::", '').gsub('Form', '').underscore
      if unwanted_fields_hash.present? && unwanted_fields_hash.keys.include?(selected_work)
        array_of_fields = unwanted_fields_hash[selected_work].split(',')
        array_of_fields.map{|ele| ele.to_sym}
      end
    end

    def primary_terms
        required_fields - remove_required_from_primary
    end

    def secondary_terms
      if not_needed_fields.present?
       terms - not_needed_fields - primary_terms -
         [:files, :visibility_during_embargo, :embargo_release_date,
          :visibility_after_embargo, :visibility_during_lease,
          :lease_expiration_date, :visibility_after_lease, :visibility,
          :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
          :member_of_collection_ids, :in_works_ids, :admin_set_id]
      else
        terms - primary_terms -
          [:files, :visibility_during_embargo, :embargo_release_date,
           :visibility_after_embargo, :visibility_during_lease,
           :lease_expiration_date, :visibility_after_lease, :visibility,
           :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
           :member_of_collection_ids, :in_works_ids, :admin_set_id]
      end
    end

  end
end

module Ubiquity
  class SharedMethods

    def self.tenant_work_list(cname_or_original_url)
      parser_class = Ubiquity::ParseTenantWorkSettings.new(cname_or_original_url)
      settings_object = parser_class.get_per_account_settings_value_from_tenant_settings("work_type_list") || parser_class.get_settings_value_from_tenant_settings("work_type_list")
      list_of_work_names_in_string_array  = settings_object && settings_object.split(',').compact
      list_of_works_classes = list_of_work_names_in_string_array  && list_of_work_names_in_string_array .map {|model| model.constantize}
      list_of_works_classes || Hyrax.config.curation_concerns
    end
  end
end

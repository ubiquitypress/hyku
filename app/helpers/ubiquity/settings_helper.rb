module Ubiquity
  module SettingsHelper

    def list_of_json_properties(metadata_field)
      tenant_settings = get_tenant_settings
      metadata_field_json_sub_keys =  tenant_settings && tenant_settings["#{metadata_field}_fields"]
      if metadata_field_json_sub_keys.present?
        metadata_field_json_sub_keys.split(',')
      else
        [ "#{metadata_field}_given_name",
                    "#{metadata_field}_family_name", "#{metadata_field}_orcid",
                    "#{metadata_field}_isni",
                    "#{metadata_field}_institutional_relationship"]
      end

    end

    def set_role_dropdown_options(metadata_field)
      tenant_settings = get_tenant_settings
      role_key = "#{metadata_field}_roles"
      options_array = metadata_field.present? ? tenant_settings.try(:present?) && tenant_settings[role_key] : nil

      if metadata_field == "creator"
        options_array || ['Faculty', 'Staff', 'Student', 'Other']
      elsif metadata_field == "contributor"
        options_array ||  ContributorGroupService.new.select_active_options.flatten.uniq!
      end
    end

    def redirect_work_url(id = nil, original_url = nil)
      redirect_hash = redirection_settings(original_url)
      if id.present? && redirect_hash.present? && redirect_hash['live'].present?
        "https://#{redirect_hash['live']}/work/#{id}"
      end
    end

    def redirect_collection_url(id = nil, original_url = nil)
      redirect_hash = redirection_settings(original_url)
      if id.present? && redirect_hash.present? && redirect_hash['live'].present?
        "https://#{redirect_hash['live']}/collection/#{id}"
      end
    end

    # THESE WILL BE GONE BY END OF THE WORK. I AM KEEPING THEM HERE SO THAT I KNOW WHAT METHODS TO REPLACE

    # def check_for_per_account_value_in_tenant_settings(settings_key)
    #   Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_per_account_settings_value_from_tenant_settings(settings_key)
    # end
    #
    # def check_for_setting_value_in_tenant_settings(settings_key)
    #   Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_settings_value_from_tenant_settings(settings_key)
    # end
    #
    # def check_for_nested_value_in_tenant_settings(settings_key1,settings_key2)
    #   Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_nested_settings_value_from_tenant_settings(settings_key1, settings_key2)
    # end

    def check_for_setting(settings_key)
      parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      parser_class.get_per_account_settings_value_from_tenant_settings(settings_key) || parser_class.get_settings_value_from_tenant_settings(settings_key)
    end

    def check_for_nested_setting(settings_key1,settings_key2)
      parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      parser_class.get_per_account_nested_settings_value_from_tenant_settings(settings_key1,settings_key2) || get_nested_settings_value_from_tenant_settings(settings_key1, settings_key2)


    private

    def redirection_settings(original_url)
      subdomain = ubiquity_url_parser(original_url)
      settings = get_tenant_settings
      if  settings.present?
        settings[subdomain]
      end
    end
  end
end

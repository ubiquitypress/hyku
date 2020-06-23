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
      options_array = check_for_setting(role_key)
      localise_dropdowns(options_array)
    end

    def localise_dropdowns(array)
      array.map{ |string|  t("hyrax.roles.#{string.parameterize(separator: '_')}") } if array.present?
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

    #passing in url with default value of nil to make it more test-able by from rails console and in test files
    def check_for_setting(settings_key, tenant_original_url = nil)
      url = tenant_original_url || request.original_url
      parser_class = Ubiquity::ParseTenantWorkSettings.new(url)
      parser_class.get_per_account_settings_value_from_tenant_settings(settings_key) || parser_class.get_settings_value_from_tenant_settings(settings_key)
    end

    def check_for_nested_setting(settings_key1,settings_key2)
      parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      parser_class.get_per_account_nested_settings_value_from_tenant_settings(settings_key1,settings_key2) || parser_class.get_nested_settings_value_from_tenant_settings(settings_key1, settings_key2)
    end


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

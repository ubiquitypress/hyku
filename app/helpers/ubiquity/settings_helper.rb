module Ubiquity
  module SettingsHelper

    def extract_required_json_property_hash(tenant_work_settings, hash_key)
      required_json_property_hash = tenant_work_settings && tenant_work_settings[hash_key]
      required_json_property_hash
    end

    def extract_licence_list(tenant_work_settings, licences )
      tenant_work_settings.presence && tenant_work_settings[licences].presence && tenant_work_settings[licences]
    end

    def list_of_json_properties(metadata_field)
        tenant_work_settings =  get_tenant_work_settings
      metadata_field_json_sub_keys =  tenant_work_settings && tenant_work_settings["#{metadata_field}_fields"]
      if metadata_field_json_sub_keys.present?
        metadata_field_json_sub_keys.split(',')
      else
        [ "#{metadata_field}_given_name",
                    "#{metadata_field}_family_name", "#{metadata_field}_orcid",
                    "#{metadata_field}_isni",
                    "#{metadata_field}_institutional_relationship"]
      end

    end

    def set_role_dropdown_options(metadata_field, tenant_work_settings)
      role_key = "#{metadata_field}_roles"
      options_array = metadata_field.present? ? tenant_work_settings.try(:present?) && tenant_work_settings[role_key] : nil

      if metadata_field == "creator"
        options_array || ['Faculty', 'Staff', 'Student', 'Other']
      elsif metadata_field == "contributor"
        options_array ||  ContributorGroupService.new.select_active_options.flatten.uniq!
      end
    end

    def redirect_work_url(id = nil, original_url = nil)
      subdomain = ubiquity_url_parser(original_url)
      redirect_hash = redirection_settings(original_url)
      if id.present? && redirect_hash.present? && redirect_hash[subdomain].present? && redirect_hash[subdomain]["url"].present?
        "#{redirect_hash[subdomain]['url']}/work/#{id}"
      end
    end

    def redirect_collection_url(id = nil, original_url = nil)
      subdomain = ubiquity_url_parser(original_url)
      redirect_hash = redirection_settings(original_url)
      if id.present? && redirect_hash.present? && redirect_hash[subdomain].present? && redirect_hash[subdomain]["url"].present?
        "#{redirect_hash[subdomain]['url']}/collection/#{id}"
      end
    end

    def check_for_per_account_value_in_tenant_settings(settings_key)
      Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_per_account_settings_value_from_tenant_settings(settings_key)
    end

    def check_for_nested_value_in_tenant_settings(settings_key1,settings_key2)
      Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_nested_settings_value_from_tenant_settings(settings_key1, settings_key2)
    end

    private

    def redirection_settings(original_url)
      work_settings = get_tenant_work_settings
      if  work_settings.present?
        work_settings["redirect_show_link"]
      end
    end

  end
end

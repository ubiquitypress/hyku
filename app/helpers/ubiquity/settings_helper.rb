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
        tenant_work_settings =return_tenant_work_settings
      creator_list =  tenant_work_settings && tenant_work_settings["#{metadata_field}_fields"]
      if creator_list.present?
        creator_list.split(',')
      else
        [ "#{metadata_field}_given_name",
                    "#{metadata_field}_family_name", "#{metadata_field}_orcid",
                    "#{metadata_field}_isni",
                    "#{metadata_field}_institutional_relationship"]
      end

    end

    def return_tenant_work_settings
      account_local_name =  ubiquity_url_parser(request.original_url)
      get_tenant_work_settings[account_local_name]
    end

  end
end

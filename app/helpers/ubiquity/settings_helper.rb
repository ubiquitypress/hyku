module Ubiquity
  module SettingsHelper

    def extract_required_json_property_hash(tenant_work_settings, hash_key)
      required_json_property_hash = tenant_work_settings[hash_key]
      required_json_property_hash && required_json_property_hash
    end

    def extract_licence_list(tenant_work_settings, licences )
      tenant_work_settings.presence && tenant_work_settings[licences].presence && tenant_work_settings[licences]
    end

  end
end

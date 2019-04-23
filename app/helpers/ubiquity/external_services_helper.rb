module Ubiquity::ExternalServicesHelper

  def check_datacite_enable?(original_url)
    get_tenant_settings_hash(original_url)['ENABLE_DOI'] == 'true'  &&  feature_list['doi_option'] == 'true' && get_tenant_settings_hash(original_url)["datacite_prefix"].present?
  end

end

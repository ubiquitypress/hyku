module Ubiquity::ExternalServicesHelper

  def check_datacite_enable?(original_url)
    get_tenant_settings_hash(original_url)['ENABLE_DOI'] == 'true'  &&  feature_list['doi_option'] == 'true' && get_tenant_settings_hash(original_url)["datacite_prefix"].present?
  end

  def display_doi_text(work_object)
    if ['Do not mint DOI', 'Keep DOI as Draft'].include?(work_object.object.model.doi_options)
      'Draft DOI'
    else
      'DOI'
    end
  end
end

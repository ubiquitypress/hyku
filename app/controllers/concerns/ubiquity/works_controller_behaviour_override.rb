module Ubiquity
  module WorksControllerBehaviourOverride
    extend ActiveSupport::Concern

    included do
      before_action :set_collection_id_and_collection_names, only: [:create, :update]
    end

    private

    def build_form
      curation_concern.account_cname = current_account.cname
      @form = work_form_service.build(curation_concern, current_ability, self)
    end

    def check_should_not_use_fedora_association
      settings_parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      tenant_work_settings_hash = settings_parser_class.per_account_tenant_settings_hash
      subdomain = settings_parser_class.get_tenant_subdomain
      tenant_work_settings_hash && tenant_work_settings_hash[subdomain] && tenant_work_settings_hash[subdomain]["turn_off_fedora_collection_work_association"]
    end

    def set_collection_id_and_collection_names
      if params[hash_key_for_curation_concern]['collection_id'].present? && check_should_not_use_fedora_association.present?
        service = Hyrax::CollectionsService.new(self)
        collection_2d_array = Hyrax::CollectionOptionsPresenter.new(service).select_options(:read)

        collection_hash = collection_2d_array.map(&:reverse).to_h
        collection_id_list = collection_hash.keys
        collection_title_list = collection_hash.values

        get_collection_names = collection_hash.values_at(*params[hash_key_for_curation_concern]['collection_id']).compact
        params[hash_key_for_curation_concern].merge!( {'collection_names' =>   get_collection_names} )

        params
      end
    end
  end
end

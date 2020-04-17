module Ubiquity
  module WorksControllerBehaviourOverride
    extend ActiveSupport::Concern

    included do
      before_action :set_collection_id_and_collection_names, only: [:create, :update]
    end

    private

    def build_form
      puts "Building form from overide"
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

    def get_work_settings
      settings_parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      settings_parser_class.tenant_work_settings_hash
    end

    def redirect?
      settings = get_work_settings
      return true if settings.present? && settings['redirect_on'] == "true"
    end


    def after_create_response
      live_url = Ubiquity::FetchTenantUrl.new(curation_concern).process_url
      respond_to do |wants|
        wants.html do
          # Calling `#t` in a controller context does not mark _html keys as html_safe
          flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
          redirect_to [main_app, curation_concern]
        end
        redirect_to live_url and return if redirect?
        wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

    def after_update_response
      if curation_concern.file_sets.present?
        return redirect_to hyrax.confirm_access_permission_path(curation_concern) if permissions_changed?
        return redirect_to main_app.confirm_hyrax_permission_path(curation_concern) if curation_concern.visibility_changed?
      end
      respond_to do |wants|
        redirect_to "https://#{get_live_url}/work/#{params[:id]}" and return if redirect?
        wants.html { redirect_to [main_app, curation_concern] }
        wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

  end
end

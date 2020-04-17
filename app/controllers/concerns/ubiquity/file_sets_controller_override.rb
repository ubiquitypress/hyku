module Ubiquity
  module FileSetsControllerOverride
    extend ActiveSupport::Concern

    private

    def get_work_settings
      settings_parser_class = Ubiquity::ParseTenantWorkSettings.new(request.original_url)
      settings_parser_class.tenant_work_settings_hash
    end

    def redirect?
      settings = get_work_settings
      return true if settings.present? && settings['redirect_on'] == "true"
    end

    def after_update_response
      live_url = Ubiquity::FetchTenantUrl.new(curation_concern).process_url
      respond_to do |wants|
        wants.html do
          redirect_to "https://#{get_live_url}/work/#{curation_concern.parent_id}" and return if redirect?
          redirect_to [main_app, curation_concern], notice: "The file #{view_context.link_to(curation_concern, [main_app, curation_concern])} has been updated."
        end
        wants.json do
          @presenter = show_presenter.new(curation_concern, current_ability)
          render :show, status: :ok, location: polymorphic_path([main_app, curation_concern])
        end
      end
    end


  end
end

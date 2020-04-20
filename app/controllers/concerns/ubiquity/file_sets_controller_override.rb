module Ubiquity
  module FileSetsControllerOverride
    extend ActiveSupport::Concern

    private

    def redirect?
      true if Ubiquity::ParseTenantWorkSettings.new(request.original_url).get_settings_value_from_tenant_work_settings('redirect_on')
    end

    def after_update_response
      live_url = Ubiquity::FetchTenantUrl.new(curation_concern.parent).process_url
      respond_to do |wants|
        wants.html do
          redirect_to live_url and return if redirect?
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

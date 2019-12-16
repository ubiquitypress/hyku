# override hyrax SelectTypeListPresenter to list worktypes on the modal based on environment variable instead of settings hyrax.config.register_curation_concern
module Ubiquity
  module SelectTypeListPresenterOverride
     extend ActiveSupport::Concern
      def authorized_models
        return [] unless @current_user

        json_data = ENV['TENANTS_WORK_SETTINGS']
        if json_data.present? && json_data.class == String
          settings_hash = JSON.parse(json_data)
          return_custom_work_list(settings_hash)

        else
          # the line below is copied from Hyrax https://github.com/samvera/hyrax/blob/v2.0.2/app/presenters/hyrax/select_type_list_presenter.rb
          @authorized_models ||= Hyrax::QuickClassificationQuery.new(@current_user).authorized_models
        end
      end

      private

      def check_work_settingsinclude_tenant_name(settings_hash)
        if settings_hash.present?
          return_custom_work_list(tenant_work_settings_hash)
        end
      end

      def return_custom_work_list(tenant_work_settings_hash)
        work_list = tenant_work_settings_hash.presence && tenant_work_settings_hash["registered_curation_concern_types"]

        work_list_array = work_list.presence && work_list.split(',')
        if work_list_array.present?
          @authorized_models = work_list_array
          @authorized_models.map{|model| model.constantize}
        else
          @authorized_models ||= Hyrax::QuickClassificationQuery.new(@current_user).authorized_models
        end
      end

  end
end

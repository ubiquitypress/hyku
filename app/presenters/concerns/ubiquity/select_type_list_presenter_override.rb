# override hyrax SelectTypeListPresenter to list worktypes on the modal based on environment variable instead of settings hyrax.config.register_curation_concern
module Ubiquity
  module SelectTypeListPresenterOverride
     extend ActiveSupport::Concern
      def authorized_models
        return [] unless @current_user
        return [] unless current_account_name
        return_custom_work_list
      end

      private

      def current_account_name
        account = Account.find_by(tenant: Apartment::Tenant.current)
        account.name if account
      end

      def return_custom_work_list
        parser_class = Ubiquity::ParseTenantWorkSettings.new(current_account_name)
        work_list = parser_class.get_per_account_settings_value_from_tenant_settings("work_type_list") || parser_class.get_settings_value_from_tenant_settings("work_type_list")
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

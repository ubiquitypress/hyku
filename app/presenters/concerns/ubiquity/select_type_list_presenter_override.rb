# override hyrax SelectTypeListPresenter to list worktypes on the modal based on environment variable instead of settings hyrax.config.register_curation_concern
module Ubiquity
  module SelectTypeListPresenterOverride
     extend ActiveSupport::Concern
      def authorized_models
        return [] unless @current_user
        json_data = ENV['TENANTS_SETTINGS']
        if json_data.present?
          settings_hash = JSON.parse(json_data)
          account = Account.find_by(tenant: Apartment::Tenant.current)
          host_name = account.cname.split('.').first
          @authorized_models = settings_hash[host_name]['registered_curation_concern_types'].split(',')
          @authorized_models.map{|model| model.constantize}
        else
          # the line below is copied from Hyrax https://github.com/samvera/hyrax/blob/v2.0.2/app/presenters/hyrax/select_type_list_presenter.rb
          @authorized_models ||= Hyrax::QuickClassificationQuery.new(@current_user).authorized_models
        end
      end
  end
end

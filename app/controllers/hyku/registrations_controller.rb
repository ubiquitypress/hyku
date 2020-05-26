module Hyku
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    def new
      settings_hash = helpers.get_tenant_settings
      subdomain = helpers.get_subdomain(request.original_url)
      return super if settings_hash[subdomain]['allow_signup'] == 'true' || settings_hash['allow_signup'] == 'true'
      redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
    end

    def create
      settings_hash = helpers.get_tenant_settings
      subdomain = helpers.get_subdomain(request.original_url)
      return super if settings_hash[subdomain]['allow_signup'] == 'true' || settings_hash['allow_signup'] == 'true'
      redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
    end

    private

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
      end
  end
end

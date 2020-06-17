module Ubiquity
  module DeviseHykuApiSessionIntegration
    extend ActiveSupport::Concern

    included do
      after_action :set_api_token , only: [:create]
      after_action :clear_jwt_token, only: [:destroy]
    end

    private

    def set_api_token
      shared_login = helpers.check_for_setting_value_in_tenant_settings("shared_login")
      if current_user && shared_login.present?
        expire = 1.hour.from_now
        token = Ubiquity::Api::JwtGenerator.encode({id: current_user.id, exp: expire})
        domain = ('.' + request.host)

        response.set_cookie(
            :jwt,
              {
                value: token, expires: expire, path: '/', same_site: :none,
                domain: domain, secure: true, httponly: true
            }
        )
      end
    end

    def clear_jwt_token
      shared_login = helpers.check_for_setting_value_in_tenant_settings("shared_login")
      if shared_login.present?
        domain = ('.' + request.host)
        response.set_cookie(
          :jwt,
            {
              value: '', expires: 10000.hours.ago, path: '/', same_site: :none,
              domain: domain, secure: true, httponly: true
            }
        )
      end
    end

  end
end

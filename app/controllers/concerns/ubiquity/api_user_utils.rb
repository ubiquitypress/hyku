module Ubiquity
  module ApiUserUtils
    extend ActiveSupport::Concern

    private

    def api_user_params
      params.permit(:email, :password, :password_confirmation, :expire)
    end

    def payload(user)
      expire =  api_user_params[:expire]
      if expire.present?
        @auth_token = Ubiquity::Api::JwtGenerator.encode({id: user.id, exp: (Time.now + expire.to_i.hours).to_i})
      else
        @auth_token = Ubiquity::Api::JwtGenerator.encode({id: user.id})
      end
    end

    def set_response_cookie(token)
      domain = ('.' + request.host)
      expire = api_user_params[:expire].try(:hour).try(:from_now) || 1.hour.from_now

      response.set_cookie(
          :jwt,
            {
              value: token, expires: expire, path: '/', same_site: :none,
              domain: domain, secure: true, httponly: true
          }
      )

    end

    def adminset_permissions(user)
      if user.present?
        AdminSet.all.map do |admin_set|
          permission_template_access = Hyrax::PermissionTemplateAccess.where(permission_template_id: admin_set.permission_template)
          {
            "#{admin_set.title.first}" => permission_template_access.find {
              |participant_access| participant_access.try(:agent_id) == user.email
             }.try(:access)
          }
        end
      end
    end

    def user_roles(user)
      if user.present?
        roles = user.roles.map {|role| role.try(:name)}.uniq
        roles - ["super_admin"]
      end
    end

  end
end

class API::V1::ApiBaseController < ActionController::Base
  include Ubiquity::ApiErrorHandlers

  before_action :switch_tenant
  before_action :get_auth_token
  before_action :authenticate_user_from_token

  helper_method :current_user, :current_account

  def current_user
    if @token_id.present?
      user = User.find_by(id: @token_id)
      @current_user = user
    end
  end

  def current_account
    if @tenant.present?
      @current_account ||= @tenant
    end
  end

  private

  def authenticate_user_from_token
    if current_user.present?
      @current_user
    end
  end

  def get_auth_token
    auth_header = request.headers['Authorization']
    if auth_header.present?
      authenticate_or_request_with_http_token do |token, options|
        jwt = Ubiquity::Api::JwtGenerator.decode(token).try(:with_indifferent_access)
        @token_id = jwt['id']
      end
    end
  end

  def find_parent
    tenant_id = params[:tenant_id] || params['tenant_id']
    @tenant ||= Account.find_by(tenant: params[:tenant_id])
  end

  def switch_tenant
    find_parent
    if @tenant && @tenant.cname.present?
      tenant_name = @tenant.cname
      AccountElevator.switch!(tenant_name)
    end
  end

end

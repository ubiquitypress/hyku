class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  force_ssl if: :ssl_configured?

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller

  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  helper_method :current_account, :admin_host?

  before_action :require_active_account!, if: :multitenant?
  before_action :set_account_specific_connections!
  before_action :authenticate_user_from_jwt_token!

  before_action :set_raven_context
  after_action :store_location


  #UbiquityPress is temporarily using redirect_to to replace raise ActionController::RoutingError, 'Not Found' in rescue_from block
  rescue_from Apartment::TenantNotFound do
    redirect_to "#{request.protocol}#{Account.admin_host}:#{request.port}/"
  end
  rescue_from ActiveFedora::ObjectNotFoundError do |exception|
    invalid_record(exception)
  end

  def store_location
    if (request.path != "/users/sign_in" &&
      request.path != "/users/sign_up" &&
      request.path != "/users/password/new" &&
      request.path != "/users/password/edit" &&
      request.path != "/users/confirmation" &&
      request.path != "/users/sign_out" &&
      !request.xhr?) # don't store ajax calls
      store_location_for(:user, request.fullpath)
    end
  end

  def authenticate_user_from_jwt_token!
    shared_login = helpers.check_for_per_account_value_in_tenant_settings("shared_login")
    token = get_auth_token

    if shared_login.present? && token.present?
      api_user = User.find_by(id: token)
    end
    if token.present? && api_user.present?
      sign_in api_user, store: false
      @current_user ||= api_user
    end
  end

  private

    def get_auth_token
      auth_header = cookies[:jwt]
      if auth_header.present?
        jwt = Ubiquity::Api::JwtGenerator.decode(auth_header).try(:with_indifferent_access)
        jwt['id']
      end
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      url_path = helpers.check_for_per_account_value_in_tenant_settings('live')
      if url_path.present?
        ("https://" + url_path).strip
      else
        root_path
      end
    end

    def require_active_account!
      return unless Settings.multitenancy.enabled
      return if devise_controller?

      raise Apartment::TenantNotFound, "No tenant for #{request.host}" unless current_account.persisted?
    end

    def set_account_specific_connections!
      #ensures superadmin can log in and shared-search is still wprking
      #users that can login as admin from the root page ie shared-search page are only in
      #postgresql schema or namespace called public hence we are doing tenant reset
      Apartment::Tenant.reset if (request.path ==  "/admin" || session[:ubiquity_super] == 'ubiquity_super')
      current_account.switch! if current_account
    end

    def multitenant?
      Settings.multitenancy.enabled
    end

    def admin_host?
      return false unless multitenant?

      Account.canonical_cname(request.host) == Account.admin_host
    end

    def current_account
      @current_account ||= Account.from_request(request)
      @current_account ||= Account.single_tenant_default
    end

    # Add context information to the lograge entries
    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:user_id] = current_user.id if current_user
      payload[:account_id] = current_account.cname if current_account
    end

    def ssl_configured?
      ActiveRecord::Type::Boolean.new.cast(Settings.ssl_configured)
    end

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end

    def invalid_record(error)
      Rails.logger.info "Application Controller error #{error}"
      redirect_to root_url, notice: "Record does not exist"
    end
end

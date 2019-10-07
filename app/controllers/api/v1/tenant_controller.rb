class API::V1::TenantController < ActionController::Base

  before_action :find_tenant, only: [:show]

  def index
    Apartment::Tenant.reset

    if params[:cname]
      @accounts = get_all_tenants_with_cname
    else
      @accounts = get_all_tenants
    end
    render json: @accounts
  end

  def show
    render json: @tenant
  end

  private

  def find_tenant
    @tenant = Account.find_by(tenant:  params[:id])
    if @tenant.present?
      @tenant
    else
      render_error("Couldn't find Account with 'tenant uuid'=#{params[:id]}")
    end
  end

  def get_all_tenants_with_cname
    if params[cname].present?
      return Account.where("cname ILIKE ?", "%#{params[:cname]}%").limit(default_limit) if params[:per_page].blank?
      Account.where("cname ILIKE ?", "%#{params[:cname]}%").limit(limit)
    end
  end

  def get_all_tenants
    if params[:per_page].present?
      Account.order('id asc').limit(params[:per_page])
    else
      Account.order('id asc')
    end
  end

  def render_error(exception)
     error = {
             status: '500',
             message: exception,
             code: 'not_found'
           }
    render json: {error: error}
  end

end

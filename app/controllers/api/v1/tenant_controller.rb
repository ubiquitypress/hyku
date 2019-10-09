class API::V1::TenantController < ActionController::Base

  before_action :set_scope
  before_action :find_tenant, only: [:show]

  def index
    if params[:cname]
      @tenants ||= get_all_tenants_with_cname
    else
      @tenants ||= get_all_tenants
    end
    if stale?(last_modified: @tenants.maximum(:updated_at), public: true)
      render json: {total: @tenants.count,  items: @tenants}
    end
  end

  def show
    if stale?(last_modified: @tenant.updated_at, public: true)
      render json: @tenant
    end
  end

  private

  def set_scope
    Apartment::Tenant.reset
  end

  def find_tenant
    @tenant ||= Account.find_by(tenant:  params[:id])
    if @tenant.present?
      @tenant
    else
      render_error("Couldn't find Account with 'tenant uuid'=#{params[:id]}")
    end
  end

  def get_all_tenants_with_cname
    if params[:cname].present?
      return Account.where("cname ILIKE ?", "%#{params[:cname]}%").where.not(parent_id: nil) if params[:per_page].blank?
      Account.where("cname ILIKE ?", "%#{params[:cname]}%").where.not(parent_id: nil).limit(params[:per_page].to_i)
    end
  end

  def get_all_tenants
    if params[:per_page].present?
      Account.order('id asc').where.not(parent_id: nil).limit(params[:per_page].to_i)
    else
      Account.order('id asc').where.not(parent_id: nil)
    end
  end

  def render_error(exception)
     error = {
             status: '400',
             message: exception,
             code: 'not_found'
           }
    render json: {error: error}
  end

end

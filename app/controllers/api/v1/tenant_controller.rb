class API::V1::TenantController < ActionController::Base

  before_action :set_scope
  before_action :find_tenant, only: [:show]

  def index
    if params[:cname]
      @tenants ||= get_all_tenants_with_cname
    else
      @tenants ||= get_all_tenants
    end
    #if stale?(last_modified: @tenants.maximum(:updated_at), public: true)
      #render json: {total: @tenants.count,  items: @tenants}
    #end
  end

  def show
    AccountElevator.switch!(@tenant.cname)
    @site = @tenant.get_site
    @content_block = @tenant.get_content_block
=begin
    if stale?(last_modified: set_last_modified, public: true)
      json_record = render_to_string(template: 'api/v1/tenant/show', locals: {tenant: @tenant})
      render json: json_record
    end
=end
    fresh_when(last_modified: set_last_modified, public: true)
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

  def set_last_modified
    site = Site.instance.updated_at
    content = ContentBlock.order('updated_at ASC').last.updated_at
    account = Account.order(updated_at: :asc).last.updated_at
    combined_updated_at = [site, content, account].compact
    combined_updated_at.max
  end

end

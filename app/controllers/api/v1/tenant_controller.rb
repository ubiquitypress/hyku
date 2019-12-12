class API::V1::TenantController < ActionController::Base

  before_action :find_tenant, only: [:show]

  def index
    if params[:name]
      @tenants ||= get_tenant_by_name
      fresh_when(last_modified: set_last_modified, public: true)
    end
  end

  def show
    @site = @tenant.get_site
    @content_block = @tenant.get_content_block
    fresh_when(last_modified: set_last_modified, public: true)
  end

  private

  def find_tenant
    @tenant ||= Account.find_by(tenant:  params[:id])
    if @tenant.present?
      @tenant
    else
      render_error("Couldn't find Account with 'tenant uuid'=#{params[:id]}")
    end
  end

  def get_tenant_by_name
    if params[:name].present?
      Account.where(name: params[:name])
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

  # def set_last_modified
  #   site = Site.instance.updated_at
  #   content = ContentBlock.order('updated_at ASC').last.updated_at
  #   account = Account.order(updated_at: :asc).last.updated_at
  #   combined_updated_at = [site, content, account].compact
  #   combined_updated_at.max
  # end

  def set_last_modified
    site = Site.instance.updated_at
    get_content_block = ContentBlock.order('updated_at ASC')
    content = get_content_block.presence && get_content_block.last.updated_at
    #account = Account.order(updated_at: :asc).last.updated_at
    account = @tenant.try(:updated_at) || @tenants.try(:first).try(:updated_at)
    combined_updated_at = [site, content, account].compact
    combined_updated_at.max
  end


end

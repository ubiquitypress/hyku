module Ubiquity
  module ApiControllerUtilityMethods
    extend ActiveSupport::Concern

    included do
      before_action :switch_tenant
    end

    private

    def find_parent
      @tenant = Account.find_by(tenant: params[:tenant_id])
    end

    def models_to_search
      'has_model_ssim:Article OR has_model_ssim:Book OR has_model_ssim:BookContribution OR has_model_ssim:ConferenceItem OR has_model_ssim: Dataset OR  has_model_ssim:ExhibitionItem OR has_model_ssim:Image OR has_model_ssim:Report OR  has_model_ssim:ThesisOrDissertation OR has_model_ssim:TimeBasedMedia OR has_model_ssim:GenericWork'
    end

    def switch_tenant
      find_parent
      tenant_name = @tenant.cname
      AccountElevator.switch!(tenant_name)
    end

    #equivalent of activefedora offset or blacklight start
    def offset
      #run this if the page number is greater than 1 other return per_page
      return limit * ([page, 1].max - 1) if page > 1
      limit
    end

   #per_page is used alongside page to calculate offset
   #limit is similar to blacklight row parameter
    def limit
      @limit ||= (params[:per_page].to_i || 0)
    end

    def page
      page = params[:page].to_i || 1
    end

    def default_limit
       5
    end

  end
end

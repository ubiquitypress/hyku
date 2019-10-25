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

    def model_list
       'Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork,Collection'
    end

    def facet_list
      ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim"]
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
      page = params[:page] || 1
      #calling  to_i incase params[:page] is a string
      #calling in the first line will means we will never return 1 since calling to_i on nil returns zero
      #
      page.to_i
    end

    def default_limit_for_hightlights
       6
    end

    def default_limit
       100
    end

    def get_records_cache_key(data, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/#{timestamp}/#{data['response']['numFound']}"
    end

    def get_records_with_pagination_cache_key(data, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/page-#{page}/per_page-#{limit}/#{timestamp}/#{data['response']['numFound']}"
    end

    def add_filter_by_class_type_cache_key(data, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/#{data['response']['docs'].first['has_model_ssim'].first.underscore}/#{timestamp}/#{data['response']['numFound']}"
    end

    def add_filter_by_class_type_with_pagination_cache_key(data, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/#{data['response']['docs'].first['has_model_ssim'].first.underscore}/page-#{page}/per_page-#{limit}/#{timestamp}/#{data['response']['numFound']}"
    end

    def add_filter_by_metadata_field_cache_key(data, metadata_key=nil, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/#{metadata_key}/#{timestamp}/#{data['response']['numFound']}"
    end

    def add_filter_by_metadata_field_with_pagination_cache_key(data, metadata_key=nil, last_updated_child = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      "multiple/#{data['response']['docs'].first['account_cname_tesim'].first}/#{metadata_key}/page-#{page}/per_page-#{limit}/#{timestamp}/#{data['response']['numFound']}"
    end

    def set_cache_last_modified_time_stamp(parent_record, child_record)
      data_updated_time = parent_record['response']['docs'].first['system_modified_dtsi']
      last_child_updated_at = child_record && child_record['response']['docs']
      if last_child_updated_at.present?
        child_timestamp = last_child_updated_at.first['system_modified_dtsi']
      else
        child_timestamp = nil
      end
       [data_updated_time, child_timestamp].compact.max
    end

  end
end

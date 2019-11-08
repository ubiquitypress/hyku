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
      "Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork,Collection"
    end

    def facet_list
      ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim"]
    end

    def solr_query_fields
      "title_tesim alt_title_tesim description_tesim keyword_tesim journal_title_tesim alternative_journal_title_tesim subject_tesim creator_tesim version_tesim related_exhibition_tesim related_exhibition_venue_tesim media_tesim duration_tesim event_title_tesim event_date_tesim event_location_tesim abstract_tesim book_title_tesim series_name_tesim edition_tesim contributor_tesim publisher_tesim place_of_publication_tesim date_published_tesim based_near_label_tesim language_tesim date_uploaded_tesim date_modified_tesim date_created_tesim rights_statement_tesim license_tesim resource_type_tesim format_tesim identifier_tesim doi_tesim qualification_name_tesim qualification_level_tesim isbn_tesim issn_tesim eissn_tesim current_he_institution_tesim extent_tesim institution_tesim org_unit_tesim refereed_tesim funder_tesim fndr_project_ref_tesim add_info_tesim date_accepted_tesim issue_tesim volume_tesim pagination_tesim article_num_tesim project_name_tesim official_link_tesim rights_holder_tesim dewey_tesim library_of_congress_classification_tesim file_format_tesim all_text_timv alt_title_tesim^4.15 editor_tesim"
    end

    def switch_tenant
      find_parent
      tenant_name = @tenant.cname
      AccountElevator.switch!(tenant_name)
    end

    def sort
      params[:sort] || "score desc, system_create_dtsi desc"
    end

    #equivalent of activefedora offset or blacklight start
    def offset
      #run this if the page number is greater than 1 other return per_page
      return limit * ([page, 1].max - 1) if page > 1
      0
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

    def get_records_with_pagination_cache_key(data, last_updated_child = nil)
        build_cache_key(data, last_updated_child)
    end

    def add_filter_by_class_type_with_pagination_cache_key(data, last_updated_child = nil)
       build_cache_key(data, last_updated_child, add_model_name = true )
    end

    def add_filter_by_metadata_field_with_pagination_cache_key(data, metadata_key=nil, last_updated_child = nil)
      build_cache_key(data, last_updated_child, metadata_key)
    end

    private

    def  build_cache_key(data, last_updated_child, metadata_key = nil, add_model_name = nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      cname = data['response']['docs'].first['account_cname_tesim'].first
      model_name = data['response']['docs'].first['has_model_ssim'].first.underscore
      record_count = data['response']['numFound']

      return "multiple/#{cname}/#{model_name}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.present?
      return "multiple/#{cname}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.blank? && metadata_key.blank?
      return "multiple/#{cname}/#{metadata_key}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if metadata_key.present?
    end

    def set_cache_last_modified_time_stamp(parent_record, child_record)
      data_updated_time = parent_record['response']['docs'].first['system_modified_dtsi']
      last_child_updated_at = get_last_child_updated_at(child_record) #child_record && child_record.dig('response', 'docs')
      if last_child_updated_at.present?
        child_timestamp = last_child_updated_at.first['system_modified_dtsi']
      else
        child_timestamp = nil
      end
       [data_updated_time, child_timestamp].compact.max
    end

    def get_last_child_updated_at(child_record)
      if child_record.class == ActiveRecord
        child_record.updated_at.utc.try(:iso8601)
      elsif child_record.class == Blacklight::Solr::Response
        child_record.dig('response', 'docs')
      end
    end

    def visibility_check
      [models_to_search, "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"]
    end

  end
end

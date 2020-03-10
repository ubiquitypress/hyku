module Ubiquity
  module ApiControllerUtilityMethods
    extend ActiveSupport::Concern

    private

    def filter_strong_params
      params.permit(:tenant_id, :id,  :per_page, :page, :q, :type, :f, :shared_search)
    end

    def models_to_search
      'has_model_ssim:Article OR has_model_ssim:Book OR has_model_ssim:BookContribution OR has_model_ssim:ConferenceItem OR has_model_ssim:Dataset OR has_model_ssim:ExhibitionItem OR
       has_model_ssim:Image OR has_model_ssim:Report OR has_model_ssim:ThesisOrDissertation OR has_model_ssim:TimeBasedMedia OR has_model_ssim:GenericWork OR has_model_ssim:BookChapter OR
       has_model_ssim:Media OR has_model_ssim:Presentation OR has_model_ssim:Uncategorized OR has_model_ssim:TextWork OR has_model_ssim:NewsClipping OR has_model_ssim:ArticleWork OR
      has_model_ssim:BookWork OR has_model_ssim:ImageWork OR has_model_ssim:ThesisOrDissertationWork'
    end

    def model_list
      "Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork,BookChapter,Media,Presentation,Uncategorized,TextWork,NewsClipping,ArticleWork,BookWork,ImageWork,ThesisOrDissertationWork,Collection"
    end

    def facet_list
      ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim"]
    end

    def solr_query_fields
      "title_tesim alt_title_tesim description_tesim keyword_tesim journal_title_tesim alternative_journal_title_tesim subject_tesim creator_tesim version_tesim related_exhibition_tesim
      related_exhibition_venue_tesim media_tesim duration_tesim event_title_tesim event_date_tesim event_location_tesim abstract_tesim book_title_tesim series_name_tesim edition_tesim
      contributor_tesim publisher_tesim place_of_publication_tesim date_published_tesim based_near_label_tesim language_tesim date_uploaded_tesim date_modified_tesim date_created_tesim
      rights_statement_tesim license_tesim resource_type_tesim format_tesim identifier_tesim doi_tesim qualification_name_tesim qualification_level_tesim isbn_tesim issn_tesim eissn_tesim
      current_he_institution_tesim extent_tesim institution_tesim org_unit_tesim refereed_tesim funder_tesim fndr_project_ref_tesim add_info_tesim date_accepted_tesim issue_tesim volume_tesim
      pagination_tesim article_num_tesim project_name_tesim official_link_tesim rights_holder_tesim dewey_tesim library_of_congress_classification_tesim file_format_tesim all_text_timv
      alt_title_tesim^4.15 editor_tesim additional_links_tesim degree_tesim irb_status_tesim irb_number_tesim source_tesim location_tesim outcome_tesim participant_tesim reading_level_tesim
      challenged_tesim photo_caption_tesim photo_description_tesim page_display_order_number_tesim is_included_in_tesim
      "
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

    def visibility_check(user = nil)
      [models_to_search].concat(filter_using_visibility(user))
    end

    def filter_using_visibility(user = nil)
      allowed_ability(user)

      if user && @current_ability.try(:admin?)
        ["-suppressed_bsi:true"]

      elsif user && user.user_key.present?
        ["({!terms f=edit_access_group_ssim}public,registered) OR ({!terms f=discover_access_group_ssim}public,registered) OR ({!terms f=read_access_group_ssim}public,registered) OR edit_access_person_ssim:#{user.user_key} OR discover_access_person_ssim:#{user.user_key} OR read_access_person_ssim:#{user.user_key}", "-suppressed_bsi:true", ""]

      elsif user.nil?
        ["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true"]
      end
    end

    def filter_work_endpoint_using_visibility(user = nil)
      allowed_ability(user)
      if user && (@current_ability.try(:admin?) || user.user_key.present? )
        filter = ["({!terms f=edit_access_group_ssim}public,registered) OR ({!terms f=discover_access_group_ssim}public,registered) OR ({!terms f=read_access_group_ssim}public,registered) OR edit_access_person_ssim:#{user.user_key} OR discover_access_person_ssim:#{user.user_key} OR read_access_person_ssim:#{user.user_key}"]
      elsif user.nil?
        filter = ["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)"]
      end
      #filter.concat([models_to_search])
    end

    def works_visibility_check(user = nil)
      [models_to_search].concat(filter_work_endpoint_using_visibility(user))
    end

    def allowed_ability(user)
      @current_ability ||= Ability.new(user)
    end

  end
end

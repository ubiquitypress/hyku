class API::V1::SearchController <  ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :set_search_default, only: [:index]
  before_action :set_default_facet_limit, only: [:facet]
  before_action :set_solr_filter_query, only: [:index]

  def index
    reset_tenants_for_shared_search
    search_by_multiple_terms
  end

  def facet
    reset_tenants_for_shared_search
    facet_name = params[:id]

    # this will create a hash key like this "f.creator_search_sim.facet.offset"
    #this ley is equivalent of start key which tells solr how many records to skip
    facet_offset_key = "f" + "." + facet_name + ".facet.offset"

    #{creates a hash key }"f.creator_search_sim.facet.limit"
    #this is similar to row key in non facet solr queries and tell solr how many facet count record to return
    facet_limit_key = "f" + "." + facet_name +  ".facet.limit"

    #This populates @fq passed as solr fq ie filter query
    if params[:f]
      params[:f].to_unsafe_h.map { |key, value| create_solr_filter_params(key, value) }
    end

    solr_params = {"qt"=>"search", q: build_query_with_term, "facet.field" => facet_name, "facet.query"=>[], "facet.pivot"=>[], "fq"=> @fq,
       "hl.fl"=>[], "rows"=>0, "qf" =>  solr_query_fields, "pf"=>"title_tesim", "facet"=>true,
        facet_limit_key => limit, facet_offset_key => facet_offset_limit, "sort"=> sort }

    response =  CatalogController.new.repository.search(solr_params)
    facet_count_list =  response['facet_counts']["facet_fields"][facet_name]
    render json: Hash[*facet_count_list]

  end

  private

  def search_by_multiple_terms
    #This populates @fq passed as solr fq ie filter query
    if params[:f]
      params[:f].to_unsafe_h.map { |key, value| create_solr_filter_params(key, value) }
    end
    #default sort uses "score desc, system_create_dtsi desc"
    response = CatalogController.new.repository.search(
       q: build_query_with_term, fq: @fq, "qf" => solr_query_fields,
      "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim",
      "institution_sim", "language_sim", "file_availability_sim"],  "sort" => sort,
       rows: limit, start: offset
       )

    @works = response
    raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "No record found for query_term: #{query_term} and filters containing #{params[:f]}") if response['response']['numFound'] == 0

  end

  def create_solr_filter_params(key, hash)
    hash.each do |item|
       @fq << "{!term f=#{key}}#{item}"
    end
  end

  def build_query_with_term
    term = params[:q]
    if term.present?
    "{!lucene}_query_:\"{!dismax v=#{term}}\" _query_:\"{!join from=id to=file_set_ids_ssim}{!dismax v=#{term}}\""
    else
      ""
    end
  end

  def set_solr_filter_query
    @fq = [search_models, "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "-suppressed_bsi:true", "", "-suppressed_bsi:true"]
  end

  def search_models
     "{!terms f=has_model_ssim}Article,Book,BookContribution,ConferenceItem,Dataset,ExhibitionItem,Image,Report,ThesisOrDissertation,TimeBasedMedia,GenericWork,Collection"
  end

  def set_search_default
    if params[:per_page].blank?
      @limit = 10
    end
  end

  def set_default_facet_limit
    if params[:per_page].blank?
      @limit = 20
    end
  end

  def reset_tenants_for_shared_search
    if params[:shared_search].present?
      #Apartment::Tenant.reset
      AccountElevator.switch!(@tenant.try(:parent).try(:cname) )
    end
  end

  #facets to skip, same as solr start paramter
  def facet_offset_limit
    if params[:per_page].present? || params[:page].present?
      facet_page = ([params[:page].to_i, 1].max - 1)
      limit * page
    else
      0
    end
  end

end

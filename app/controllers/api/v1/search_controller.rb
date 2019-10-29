class API::V1::SearchController <  ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :set_search_default, only: [:index]
  
  def index
    reset_tenants_for_shared_search
    if params[:f].present?
      search_by_multiple_terms
    elsif params[:q].present? &&  params[:f].blank?
      filter_by_single_query_term
    else
      query_all
    end
  end

  private

  def query_all
    response = CatalogController.new.repository.search(
       q: '', fq: models_to_search, "qf" => solr_query_fields,
      "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim",
      "institution_sim", "language_sim", "file_availability_sim"],  "sort" => "score desc, system_create_dtsi desc",
       rows: limit, start: offset
       )

       @works = response
  end

  def get_query_params
    extracted_params = request.query_parameters.except(*['per_page', 'page'])
    metadata_field = extracted_params.keys.first.try(:to_sym)
    value = extracted_params[metadata_field]
  end


  def filter_by_single_query_term
    response = CatalogController.new.repository.search(
       q: params[:q], "qf" => solr_query_fields,
      "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim",
      "institution_sim", "language_sim", "file_availability_sim"],  "sort" => "score desc, system_create_dtsi desc",
       rows: limit, start: offset
       )

       @works = response
  end

  def search_by_multiple_terms
    q = params[:q] || ''
    @fq = []
    hash = params[:f]

    hash.to_unsafe_h.map do |key, value|
      create_solr_filter_params(key, value)
    end

    response = CatalogController.new.repository.search(
       q: '', fq: @fq, "qf" => solr_query_fields,
      "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim",
      "institution_sim", "language_sim", "file_availability_sim"],  "sort" => "score desc, system_create_dtsi desc",
       rows: limit, start: offset
       )

    @works = response
  end

  def create_solr_filter_params(key, hash)
    hash.each do |item|
       @fq << "{!term f=#{key} }#{item}"
    end
  end

  def set_search_default
    if params[:per_page].blank?
      @limit = 10
    end
  end

  def reset_tenants_for_shared_search
    if params[:shared_search].present?
      #Apartment::Tenant.reset
      AccountElevator.switch!(@tenant.try(:parent).try(:cname) )
    end
  end

end

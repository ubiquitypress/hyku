class API::V1::CollectionController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :fetch_collection, only: [:show]

  def index
    @collections = get_all_collections

    #fresh_when(last_modified: @collections.first.to_solr["system_modified_dtsi"].try(:to_time), public: true)
  end

  def show
    @single_collection = @collection
  end

  private

  def fetch_collection
    collection =  CatalogController.new.repository.search(q: "id:#{params[:id]}")
    @collection  = collection['response']["docs"].first
  end

  def get_all_collections
    total_record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:Collection" , rows: 0)
    total_count = total_record['response']['numFound']

    return collection = CatalogController.new.repository.search(q: '', fq: "has_model_ssim:Collection", "sort"=>"score desc, system_create_dtsi desc",
    "facet.field"=>["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
    "language_sim", "file_availability_sim"], rows: limit, start: offset) if params[:per_page].present? && offset < total_count

    @limit = default_limit

    collection = CatalogController.new.repository.search(q: '', fq: "has_model_ssim:Collection", "sort"=>"score desc, system_create_dtsi desc",
    "facet.field"=>["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
    "language_sim", "file_availability_sim"], rows: limit) if params[:per_page].blank? || offset > total_count

  end

end

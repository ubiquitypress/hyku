class API::V1::CollectionController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :fetch_collection, only: [:show]

  def index
    get_all_collections
  end

  def show
    last_modified = Time.parse(@collection["system_modified_dtsi"])
    fresh_when(last_modified: last_modified, public: true)
  end

  private

  def fetch_collection
    collection =  CatalogController.new.repository.search(q: "id:#{params[:id]}")
    @collection  = collection['response']["docs"].first
    if @collection.present?
      @collection
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "There is no record with id: #{params[:id]}")
    end
  end

  def get_all_collections
    record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:Collection" , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    record_data = record.dig('response','docs')
    collection_id = record_data.presence && record_data.first['id']
    last_updated_child  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']

    if record.dig('response','docs').try(:present?) && params[:per_page].present? && offset < total_count
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      collections_json  = Rails.cache.fetch(set_cache_key) do
        @collections = CatalogController.new.repository.search(q: '', fq: "has_model_ssim:Collection", "sort"=>"score desc, system_create_dtsi desc",
        "facet.field"=>["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
        "language_sim", "file_availability_sim"], rows: limit, start: offset)
        render_to_string(:template => 'api/v1/collection/index.json.jbuilder', locals: {collections: @collections})
      end
      render json: collections_json
    elsif record.dig('response','docs').try(:present?) &&  params[:per_page].blank? || offset > total_count
      set_cache_key = add_filter_by_class_type_cache_key(record, last_updated_child)
      @limit = default_limit
      collections_json  = Rails.cache.fetch(set_cache_key) do
        @collections = CatalogController.new.repository.search(q: '', fq: "has_model_ssim:Collection", "sort"=>"score desc, system_create_dtsi desc",
        "facet.field"=>["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
        "language_sim", "file_availability_sim"], rows: limit)
        render_to_string(:template => 'api/v1/collection/index.json.jbuilder', locals: {collections: @collections})
      end
      render json: collections_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This tenant has no collection")
    end

  end

end

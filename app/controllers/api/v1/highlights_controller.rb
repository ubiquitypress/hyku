class API::V1::HighlightsController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :set_limit

  def index
    #if nil is reurned, we replace it with "null", JSON.parse can return nil
    collections = get_collections || "null"
    @featured_works = get_featured_works || "null"
    @recent_documents =  get_recent_documents || "null"
   render json: {explore_collections: JSON.parse(collections), featured_works: JSON.parse(@featured_works), recent_works: JSON.parse(@recent_documents) }
  end

  private

  def get_collections
    record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:Collection" , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    collection_id = record['response']['docs'].first['id']
    last_updated_child  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    if record.present?
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      collections_json  = Rails.cache.fetch(set_cache_key) do
        @collections  = CatalogController.new.repository.search(q: 'id:*', fq: 'has_model_ssim:Collection', rows: limit, sort: 'system_created_dtsi desc')
        render_to_string(:template => 'api/v1/collection/index.json.jbuilder', locals: {collections: @collections})
      end
    end
  end

  def get_recent_documents
    record =  CatalogController.new.repository.search(q: "id:*", fq: models_to_search , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record['response']['docs'].first["file_set_ids_ssim"]
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids.join(',')}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    if record.present?
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      works_json =  Rails.cache.fetch(set_cache_key) do
        @works = CatalogController.new.repository.search(:q=>"id:*", sort: 'system_create_dtsi desc', rows: limit, fq: models_to_search)
        render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})
      end
    end
  end

  def get_featured_works
    featured_works = FeaturedWorkList.new.featured_works
    ids = featured_works.map(&:work_id)

    record = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"], rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    file_ids = record['response']['docs'].first["file_set_ids_ssim"]
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{file_ids.join(',')}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    if record.present?
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      works_json =  Rails.cache.fetch(set_cache_key) do
        @works = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"], rows: limit)
        render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})
      end
    end

  end

  def set_limit
    if params[:per_page].blank?
      @limit = default_limit_for_hightlights
    end
  end

end

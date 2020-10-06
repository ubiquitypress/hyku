class API::V1::CollectionController <   API::V1::ApiBaseController
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiCacheKeyGenerator

  before_action :fetch_collection, only: [:show]

  def index
    get_all_collections
  end

  def show
  end

  private

  def api_params
    params.permit(:group_parent_field, :group_child_field, :group_limit, :tenant_id, :id )
  end

  def fetch_collection
    @skip_run = 'true'
    @grouping_hash = api_params
    if current_user.present?
      #collection =   Rails.cache.fetch("single/collection/#{@tenant.cname}/#{params[:id]}") do
      collection = CatalogController.new.repository.search(q: "id:#{params[:id]}", fq: ["has_model_ssim:Collection"].concat(filter_using_visibility(current_user)) )
      #end
    else
      collection =  CatalogController.new.repository.search(q: "id:#{params[:id]}", fq: ["has_model_ssim:Collection"].concat(filter_using_visibility) )
    end
    @collection  = collection['response']["docs"].first
    if @collection.present?
      @collection
      json = render_to_string(:partial => 'api/v1/collection/collection.json.jbuilder', locals: {single_collection: @collection})
      render json: json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This is either a private collection or there is no record with id: #{params[:id]}")
    end
  end

  def get_all_collections
    record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:Collection" , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    record_data = record.dig('response','docs')
    collection_id = record_data.presence && record_data.first['id']

    using_works_in_collecton  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    using_collection_ids_in_works  = CatalogController.new.repository.search(q: "collection_id_sim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    combined_record =  using_works_in_collecton['response']['docs'] | using_collection_ids_in_works['response']['docs']
    using_collection_ids_in_works['response']['docs'] = combined_record
    using_collection_ids_in_works['response']['numFound'] = combined_record.size
    last_updated_child  = using_collection_ids_in_works

    total_count = record['response']['numFound']
    @limit = default_limit if params[:per_page].blank?

    if record.dig('response','docs').try(:present?) && current_user.present?
      # set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      #collections_json  = Rails.cache.fetch(set_cache_key) do
        @collections = CatalogController.new.repository.search(q: '', fq: ["has_model_ssim:Collection"].concat(filter_using_visibility(current_user)),
                        "sort"=>"score desc, system_create_dtsi desc",  rows: limit, start: offset)
        collections_json = render_to_string(:template => 'api/v1/collection/index.json.jbuilder', locals: {collections: @collections})
      #end
      render json: collections_json
    elsif record.dig('response','docs').try(:present?)
      @collections = CatalogController.new.repository.search(q: '', fq: ["has_model_ssim:Collection"].concat(filter_using_visibility),
                      "sort"=>"score desc, system_create_dtsi desc",  rows: limit, start: offset)
      collections_json = render_to_string(:template => 'api/v1/collection/index.json.jbuilder', locals: {collections: @collections})
      render json: collections_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This tenant has no collection")
    end

  end

end

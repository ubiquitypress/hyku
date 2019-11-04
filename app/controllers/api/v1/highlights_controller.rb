class API::V1::HighlightsController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  #include Ubiquity::ApiErrorHandlers
  before_action :set_limit

  def index
    @collections = get_collections || []
    @featured_works = get_featured_works || []
    @recent_documents =  get_recent_documents || []
   json = Rails.cache.fetch("multiple/highlights/#{@tenant.try(:cname)}/#{set_last_modified_date}") do
            render_to_string(:template => 'api/v1/highlights/index.json.jbuilder', locals: {collections: @collections, featured_works: @featured_works,
                  recent_documents: @recent_documents })
          end

   render json: json

  end

  private

  def get_collections
    record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:Collection" , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    collection_id = record.dig('response','docs').presence && record.dig('response','docs').first['id']
    last_updated_child  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      collections_json  = Rails.cache.fetch(set_cache_key) do
        CatalogController.new.repository.search(q: 'id:*', fq: 'has_model_ssim:Collection', rows: limit, sort: 'system_created_dtsi desc')
      end
    end
  end

  def get_recent_documents
    record =  CatalogController.new.repository.search(q: "id:*", fq: models_to_search , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record && record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      Rails.cache.fetch(set_cache_key) do
        CatalogController.new.repository.search(:q=>"id:*", sort: 'system_create_dtsi desc', rows: limit, fq: models_to_search)
      end
    end
  end

  def get_featured_works
    featured_works = FeaturedWorkList.new.featured_works
    ids = featured_works.map(&:work_id)
    joined_ids =  ids.present? ? ids.join(',') : nil
    record = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{joined_ids}"], rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    file_ids = record && record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      Rails.cache.fetch(set_cache_key) do
        data = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"], rows: limit)
        #Re-order to the solr response to match the order that was work was featured in
        puts "lawal #{data['response']['docs']}"
        ordered_values = data['response']['docs'].group_by {|hash| hash['id']}.values_at(*ids).flatten
        data['response']['docs'] = ordered_values
        data
      end
    end

  end

  def set_limit
    if params[:per_page].blank?
      @limit = default_limit_for_hightlights
    end
  end

  def set_last_modified_date
    collection_records = get_collections.presence && get_collections['response']['docs'].try(:first).dig('system_modified_dtsi')
    featured_records = get_featured_works.presence && get_featured_works['response']['docs'].map{|h| h['system_modified_dtsi']}.try(:max) #try(:first).dig('system_modified_dtsi')
    recent_records = get_recent_documents.presence && get_recent_documents['response']['docs'].try(:first).dig('system_modified_dtsi')
    dates_array = [collection_records, featured_records, recent_records].compact.max
  end

end

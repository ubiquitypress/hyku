class API::V1::HighlightsController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :set_limit

  def index
    #@highlight_skip_run = 'false'
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
    #last_updated_child  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    using_works_in_collecton  = CatalogController.new.repository.search(q: "member_of_collection_ids_ssim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    using_collection_ids_in_works  = CatalogController.new.repository.search(q: "collection_id_sim:#{collection_id}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    combined_record =  using_works_in_collecton['response']['docs'] | using_collection_ids_in_works['response']['docs']
    using_collection_ids_in_works['response']['docs'] = combined_record
    using_collection_ids_in_works['response']['numFound'] = combined_record.size
    last_updated_child  = using_collection_ids_in_works
    
    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      fq = ['has_model_ssim:Collection', "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)"]
      collections_json  = Rails.cache.fetch(set_cache_key) do
        CatalogController.new.repository.search(q: 'id:*', fq: fq, rows: limit, sort: 'system_created_dtsi desc')
      end
    end
  end

  def get_recent_documents
    record =  CatalogController.new.repository.search(q: "id:*", fq: models_to_search , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record && record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"] ,  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      Rails.cache.fetch(set_cache_key) do
        CatalogController.new.repository.search(:q=>"id:*", sort: 'system_create_dtsi desc', rows: limit, fq: visibility_check)
      end
    end
  end

  def get_featured_works
    @featured = FeaturedWorkList.new.featured_works
    ids = @featured.map(&:work_id)
    joined_ids =  ids.present? ? ids.join(',') : nil
    record = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{joined_ids}"], rows: 1, "sort" => "score desc, system_modified_dtsi desc")

    file_ids = record && record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    recently_updated = recency_between_files_and_featured_work(last_updated_child)
    if record.dig('response','docs').try(:present?)
      set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, recently_updated)
      Rails.cache.fetch(set_cache_key) do
        data = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"], rows: limit)
      end
    end
  end

  def recency_between_files_and_featured_work(last_updated_child)
    latest_featured = @featured.try(:max)
    latest_file_from_work = last_updated_child['response']['docs'].presence && last_updated_child['response']['docs'].first['system_modified_dtsi']
    latest_from_time_stamp = [latest_featured.to_s, latest_file_from_work.to_s].max
    if latest_from_time_stamp == latest_featured
      @featured
    else
       last_updated_child
    end
  end

  def set_limit
    if params[:per_page].blank?
      @limit = default_limit_for_hightlights
    end
  end

  def set_last_modified_date
    collection_records = get_collections.presence && get_collections['response']['docs'].try(:first).dig('system_modified_dtsi')
    featured_records = get_featured_works.presence && get_featured_works['response']['docs'].map{|h| h['system_modified_dtsi']}.try(:max)
    recent_records = get_recent_documents.presence && get_recent_documents['response']['docs'].try(:first).dig('system_modified_dtsi')
    featured_works = recent_updated_featured_works_time_stamp
    dates_array = [collection_records, featured_records, recent_records, featured_works].compact.max
  end

  def recent_updated_featured_works_time_stamp
    @featured && @featured.map{|record| record.updated_at}.try(:max).try(:to_time).try(:utc).try(:iso8601)
  end

end

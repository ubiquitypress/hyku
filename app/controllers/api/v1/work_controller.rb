class API::V1::WorkController < API::V1::ApiBaseController
  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiCacheKeyGenerator

  before_action :fetch_work, only: [:show, :manifest]

  def index
    if request.query_parameters.blank? || request.query_parameters.keys.to_set == ["per_page", "page"].to_set || request.query_parameters.keys == ["per_page"]
      fetch_all_works
    elsif params[:type].present?
      filter_by_resource_type
    else
      filter_by_metadata
    end
  end

  def show
    render json: render_to_string(:partial => 'api/v1/work/work.json.jbuilder', locals: {work: @work})
  end

  def manifest
    work_class = @work['has_model_ssim'].first.pluralize
    controller_in_use = "Hyrax::#{work_class}Controller".camelize.constantize.new
    request.env["HTTP_HOST"]  = @work['account_cname_tesim'].try(:first)
    controller_in_use.request = request
    controller_in_use.response = response
    controller_in_use.sign_in current_user if current_user
    record = controller_in_use.manifest
    render json: record
  end

  private

  def fetch_work
    @skip_run = 'true'
    if current_user.present?
      work = CatalogController.new.repository.search(q: "id:#{params[:id]}", fq: works_visibility_check(current_user), qf: solr_query_fields)
    else
      work = CatalogController.new.repository.search(q: "id:#{params[:id]}", fq: works_visibility_check, qf: solr_query_fields)
    end
    work = work.presence && work['response']['docs'].first
    if work.present?
      @work = work
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This is either a private work or there is no record with id: #{params[:id]}")
    end
  end

  def fetch_all_works
    record = CatalogController.new.repository.search(q: "id:*", fq: models_to_search , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    @limit = default_limit if params[:per_page].blank?

    if record.dig('response','docs').try(:present?) && current_user.present?
      #something similar to multiple/library.localhost/2019-10-21T14:02:35Z/53
      # set_cache_key = get_records_with_pagination_cache_key(record, last_updated_child)
      @works = CatalogController.new.repository.search(q: '', fq: works_visibility_check(current_user), "sort" => "score desc, system_create_dtsi desc",
          rows: limit, start: offset)
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works })
      render json: works_json

    elsif record.dig('response','docs').try(:present?)
      @works = CatalogController.new.repository.search(q: '', fq: works_visibility_check, "sort" => "score desc, system_create_dtsi desc",
       rows: limit, start: offset)
       works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works })
       render json: works_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This tenant has no works")
    end

  end

  def filter_by_resource_type
    record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:#{params[:type].camelize.constantize}" , rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    @limit = default_limit if params[:per_page].blank?

    if record.dig('response','docs').try(:present?) && current_user.present?
      #returns keys like multiple/library.localhost/article/page-0/per_page-2/2019-07-10T14:10:50Z/14
      # set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      fq = filter_work_endpoint_using_visibility(current_user) << "has_model_ssim:#{params[:type].camelize.constantize}"

      @works = CatalogController.new.repository.search(q: "id:*", fq: fq, rows: limit, start: offset )
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    elsif record.dig('response','docs').try(:present?)
      # set_cache_key = add_filter_by_class_type_with_pagination_cache_key(record, last_updated_child)
      fq = filter_work_endpoint_using_visibility << "has_model_ssim:#{params[:type].camelize.constantize}"

      @works = CatalogController.new.repository.search(q: "id:*", fq: fq, rows: limit, start: offset )
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "This tenant has no #{params[:type].pluralize}")
    end

  end

  def filter_by_metadata
    extracted_params = request.query_parameters.except(*['per_page', 'page'])
    metadata_field = extracted_params.keys.first.try(:to_sym)
    value = extracted_params[metadata_field]
    if [:availability].include? metadata_field
      fetch_by_file_availability(metadata_field, value)
    else
      fetch_by_other_metatdata_fields(metadata_field, value)
    end
  end

  def fetch_by_file_availability(metadata_field, value)
    record = CatalogController.new.repository.search(q: "id:*", fq: ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"], rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    @limit = default_limit if params[:per_page].blank?

    if record.dig('response','docs').try(:present?) && current_user.present?
      # set_cache_key = add_filter_by_metadata_field_with_pagination_cache_key(record, metadata_field, last_updated_child)
      fq = ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"].concat(filter_work_endpoint_using_visibility(current_user) )
      @works =  CatalogController.new.repository.search(:q=>"", fq: fq, rows: limit, start: offset)
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    elsif record.dig('response','docs').try(:present?)
      # set_cache_key = add_filter_by_metadata_field_with_pagination_cache_key(record, metadata_field, last_updated_child)
      fq = ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"].concat(filter_work_endpoint_using_visibility)
      @works =  CatalogController.new.repository.search(:q=>"", fq: fq, rows: limit, start: offset)
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "There are no results for this query")
    end
  end

  def fetch_by_other_metatdata_fields(metadata_field, value)
    record = CatalogController.new.repository.search(q:  "#{map_search_keys[metadata_field]}:#{value}", rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    total_count = record['response']['numFound']
    file_ids = record['response']['docs'].presence && record['response']['docs'].first["file_set_ids_ssim"]
    new_file_ids = file_ids.present? ? file_ids.join(',') : nil
    last_updated_child = CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{new_file_ids}"],  rows: 1, "sort" => "score desc, system_modified_dtsi desc")
    @limit = default_limit if params[:per_page].blank?

    if record.dig('response','docs').try(:present?) && current_user.present?
      # set_cache_key = add_filter_by_metadata_field_with_pagination_cache_key(record, metadata_field, last_updated_child)
      @works =  CatalogController.new.repository.search(q: "#{map_search_keys[metadata_field]}:#{value}", rows: limit, start: offset, fq: works_visibility_check(current_user) )
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    elsif record.dig('response','docs').try(:present?)
      # set_cache_key = add_filter_by_metadata_field_with_pagination_cache_key(record, metadata_field, last_updated_child)
      @works =  CatalogController.new.repository.search(q: "#{map_search_keys[metadata_field]}:#{value}", rows: limit, start: offset, fq: works_visibility_check)
      works_json = render_to_string(:template => 'api/v1/work/index.json.jbuilder', locals: {works: @works})

      render json: works_json
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "There are no results for this query")
    end
  end

  def map_search_keys
      {
        creator: 'creator_tesim', keyword: 'keyword_sim',
        collection_uuid: 'member_of_collection_ids_ssim',
        language: 'language_sim',  availability: 'file_availability_sim'
      }
  end

  def map_search_values
    {
       not_available: 'File not available', available: 'File available from this repository', external_link:  'External link (access may be restricted)'
    }
  end

end

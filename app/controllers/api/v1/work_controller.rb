class API::V1::WorkController < ActionController::Base
  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

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
    #fresh_when(etag: @fedora_work, last_modified: @fedora_work.date_modified, public: true)
  end

  def manifest
    work_class = @work['has_model_ssim']
    controller_in_use = "Hyrax::#{work_class}Controller".camelize.constantize.new
    request.env["HTTP_HOST"]  = @work['account_cname_tesim']
    controller_in_use.request = request
    controller_in_use.response = response
    record = controller_in_use.manifest
    render json: record
  end

  private

  def fetch_work
    work = CatalogController.new.repository.search(q: params[:id],  "sort" => "score desc, system_create_dtsi desc",
    "facet.field "=> ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
    "language_sim", "file_availability_sim"])

    @work = work['response']['docs'].first
  end

  def fetch_all_works
    total_record = CatalogController.new.repository.search(q: "id:*", fq: models_to_search , rows: 0)
    total_count = total_record['response']['numFound']

    return @works = CatalogController.new.repository.search(q: '', fq: models_to_search, "sort" => "score desc, system_create_dtsi desc",
    "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
    "language_sim", "file_availability_sim"], rows: limit, start: offset) if params[:per_page].present? && offset < total_count

    @limit = default_limit

    @works = CatalogController.new.repository.search(q: '', fq: models_to_search, "sort" => "score desc, system_create_dtsi desc",
    "facet.field" => ["resource_type_sim", "creator_search_sim", "keyword_sim", "member_of_collections_ssim", "institution_sim",
    "language_sim", "file_availability_sim"], rows: limit) if params[:per_page].blank? || offset > total_count
  end

  def filter_by_resource_type
    total_record = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:#{params[:type].camelize.constantize}" , rows: 0)
    total_count = total_record['response']['numFound']
    return @works = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:#{params[:type].camelize.constantize}", rows: limit, start: offset ) if params[:per_page].present? && offset < total_count

    @limit = default_limit

    @works = CatalogController.new.repository.search(q: "id:*", fq: "has_model_ssim:#{params[:type].camelize.constantize}", rows: limit ) if params[:per_page].blank? || offset > total_count
  end

  def filter_by_metadata
    extracted_params = request.query_parameters.except(*['per_page', 'page'])
    metadata_field = extracted_params.keys.first.try(:to_sym)

    value = extracted_params[metadata_field]

    if [:availability].include? metadata_field

     total_record = CatalogController.new.repository.search(q: "id:*", fq: ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"], rows: 0)
     total_count = total_record['response']['numFound']

     return @works =  CatalogController.new.repository.search(:q=>"", fq: ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"], rows: limit, start: offset) if params[:per_page].present? && offset < total_count

     @limit = default_limit

     @works =  CatalogController.new.repository.search(:q=>"", rows: limit, fq: ["{!term f=file_availability_sim}#{map_search_values[value.to_sym]}", "{!terms f=has_model_ssim}#{model_list}"])  if params[:per_page].blank? || offset > total_count

   else

     total_record = CatalogController.new.repository.search(q:  "#{map_search_keys[metadata_field]}:#{value}", rows: 0)
     total_count = total_record['response']['numFound']

     return @works =  CatalogController.new.repository.search(q: "#{map_search_keys[metadata_field]}:#{value}", rows: limit, start: offset) if params[:per_page].present? && offset < total_count
     @limit = default_limit

     @works =  CatalogController.new.repository.search(q: "#{map_search_keys[metadata_field]}:#{value}", rows: limit) if params[:per_page].blank? || offset > total_count

   end

  end

  def add_caching(search_query)
    record = ActiveFedora::Base.where(search_query)
    if record.present?
      fresh_when(last_modified: record.order('system_modified_dtsi desc').last.date_modified.to_time,
                public: true)
    end
  end

  def map_search_keys
      {
        creator: 'creator_tesim',
        keyword: 'keyword_sim',
        collection_uuid: 'member_of_collection_ids_ssim',
        language: 'language_sim',
        availability: 'file_availability_sim'
      }
  end

  def map_search_values
    {
       not_available: 'File not available',
       available: 'File available from this repository',
       external_link:  'External link (access may be restricted)'
    }
  end

end

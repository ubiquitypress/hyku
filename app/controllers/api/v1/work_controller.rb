class API::V1::WorkController < ActionController::Base
  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :get_fedora_work, only: [:show]

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
    fresh_when(etag: @fedora_work, last_modified: @fedora_work.date_modified, public: true)
  end

  def manifest
    work_class = ActiveFedora::Base.find(params[:id]).class.to_s.pluralize
    controller_in_use = "Hyrax::#{work_class}Controller".camelize.constantize.new
    controller_in_use.request = request
    controller_in_use.response = response
    record = controller_in_use.manifest
    render json: record
  end

  private

  def get_fedora_work
    @fedora_work = ActiveFedora::Base.find(params[:id])
  end

  def fetch_all_works
    @total_count = ActiveFedora::Base.where(models_to_search).count
    return @works = ActiveFedora::Base.where(models_to_search).order('system_create_dtsi desc').offset(offset).limit(limit) if limit != 0 && offset < @total_count
     @works = ActiveFedora::Base.where(models_to_search).order('system_create_dtsi desc')
     fresh_when(etag: @works,
                last_modified: ActiveFedora::Base.where(models_to_search).order('system_modified_dtsi desc').last.date_modified.to_time,
                 public: true)

  end

  def filter_by_resource_type
    klass =  params[:type].camelize.constantize
    @total_count = klass.order('system_create_dtsi desc').count
    return  @works = klass.order('system_create_dtsi desc').offset(offset).limit(limit) if limit != 0 && offset < @total_count
    @works = klass.order('system_create_dtsi desc')
    fresh_when(etag: @works,
               last_modified: ActiveFedora::Base.where("has_model_ssim:#{params[:type].camelize}").order('system_modified_dtsi desc').last.date_modified.to_time,
                public: true)
  end

  def filter_by_metadata
    extracted_params = request.query_parameters.except(*['per_page', 'page'])
    metadata_field = extracted_params.keys.first.try(:to_sym)
    value = extracted_params[metadata_field]

    if metadata_field.present? && [:availability].include?(metadata_field)
      query_by_availability(metadata_field, value)
    elsif [:collection_uuid].include? metadata_field
      query_by_collection(metadata_field, value)
    elsif metadata_field.present?
      query_by_metadata(metadata_field, value)
    else
      raise Ubiquity::ApiError::BadRequest.new(status: 400, code: 'Bad Request', message: "Please check the request path #{request.path} & ensure you add per_page if you send back just #{request.original_fullpath}. That is do not send only ?page=number given" )
    end
  end

  def query_by_availability(metadata_field, value)
    @total_count =  ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{map_search_values[value.to_sym]}").count
    if limit != 0  && offset < @total_count
      @works = ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{map_search_values[value.to_sym]}").offset(offset).limit(limit)
    else
      @works = ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{map_search_values[value.to_sym]}")
    end
    raise Ubiquity::ApiError::NotFound.new(status: '404', code: 'not_found', message: "No record was found for #{metadata_field} with value of #{value}")  if @works.blank?
    add_caching("#{map_search_keys[metadata_field]}:#{map_search_values[value.to_sym]}")
  end

  def query_by_collection(metadata_field, value)
    collection = Collection.find(value)
    @total_count = collection.try(:member_objects).try(:count)
    @works = collection.try(:member_objects)
    raise Ubiquity::ApiError::NotFound.new(status: '404', code: 'not_found', message: "Collection with id #{value} has no works")  if @works.blank?
    #collection.member_objects returns the most recently modified  work first
    fresh_when(etag: @works, last_modified: [@works.first.date_modified.to_time, collection.to_solr["system_modified_dtsi"].try(:to_time)].compact.max, public: true)
  end

  def query_by_metadata(metadata_field, value)
    @total_count = ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{value}").count
    if limit != 0 && offset < @total_count
      @works = ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{value}").offset(offset).limit(limit)
    else
      @works = ActiveFedora::Base.where("#{map_search_keys[metadata_field]}:#{value}")
    end
    raise Ubiquity::ApiError::NotFound.new(status: '404', code: 'not_found', message: "No record was found for #{metadata_field} with value of #{value}")  if @works.blank?
    add_caching("#{map_search_keys[metadata_field]}:#{value}")
  end

  def add_caching(search_query)
    record = ActiveFedora::Base.where(search_query)
    if record.present?
      fresh_when(etag: @works,
               last_modified: record.order('system_modified_dtsi desc').last.date_modified.to_time,
                public: true)
    end
  end

  def map_search_keys
      {
        creator: 'creator_tesim',
        keyword: 'keyword_sim',
        collection_uuid: 'id',
        collection_name: 'member_of_collections_ssim',
        language: 'language_sim',
        availability: 'file_availability_tesim'
      }
  end

  def map_search_values
    {
       not_available: 'File+not+available',
       available: 'File+available+from+this+repository',
       external_link: 'External+link+access+may+be+restricted'
    }
  end

end

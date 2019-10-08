class API::V1::CollectionController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  before_action :fetch_collection, only: [:show]

  def index
    @collections = get_all_collections
    fresh_when(etag: @collections,
                 last_modified: Collection.order('system_modified_dtsi desc').last.date_modified.try(:to_time),
                  public: true)
  end

  def show
    if stale?(etag: @collection, last_modified: @collection.date_modified.try(:to_time), public: true)
      @collection
    end
  end

  private

  def fetch_collection
    @collection = Collection.find(params[:id])
  end

  def get_all_collections
    @total_count = Collection.try(:count)
    return  Collection.order('system_create_dtsi desc').offset(offset).limit(limit) if limit != 0 && offset < @total_count
    Collection.order('system_create_dtsi desc')
  end

end

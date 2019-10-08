class API::V1::HighlightsController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  def index
    @collections = get_collections
    @featured_works = get_featured_works
    @recent_documents =  get_recent_documents
    last_modified = [@collections.first.to_solr["system_modified_dtsi"].try(:to_time), @featured_works.last.try(:date_modified).try(:to_time), @recent_documents.last.try(:date_modified).try(:to_time)].compact.max
    fresh_when(etag: [@collections, @featured_works, @recent_documents],
                 last_modified: last_modified,
                  public: true)
  end

  private

  def get_collections
    return  Collection.order('system_create_dtsi desc').limit(default_limit) if params[:per_page].blank?
    Collection.order('system_create_dtsi desc').limit(limit)
  end

  def get_recent_documents
    return ActiveFedora::Base.where(models_to_search).order('system_create_dtsi desc').limit(default_limit) if params[:per_page].blank?
    ActiveFedora::Base.where(models_to_search).order('system_create_dtsi desc').limit(limit)
  end

  def get_featured_works
    featured_works = FeaturedWorkList.new.featured_works
    ids = featured_works.map(&:work_id)
    if params[:per_page].blank?
      records = ActiveFedora::Base.where(id: ids).limit(default_limit)
    else
      records = ActiveFedora::Base.where(id: ids).limit(limit)
      records
    end
  end

end

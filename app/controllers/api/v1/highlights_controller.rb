class API::V1::HighlightsController < ActionController::Base

  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :set_limit

  def index

    @collections = get_collections
    @featured_works = get_featured_works
    @recent_documents =  get_recent_documents
    #last_modified = [@collections.first.to_solr["system_modified_dtsi"].try(:to_time), @featured_works.last.try(:date_modified).try(:to_time), @recent_documents.last.try(:date_modified).try(:to_time)].compact.max
    #fresh_when(last_modified: last_modified, public: true)

  end

  private

  def get_collections
    CatalogController.new.repository.search(q: 'id:*', fq: 'has_model_ssim:Collection', rows: limit, sort: 'system_created_dtsi desc')
  end

  def get_recent_documents
    CatalogController.new.repository.search(:q=>"id:*", sort: 'system_create_dtsi desc', rows: limit, fq: models_to_search)
  end

  def get_featured_works
    featured_works = FeaturedWorkList.new.featured_works
    ids = featured_works.map(&:work_id)
    if params[:per_page].blank?
      CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"])
    else
      CatalogController.new.repository.search(q: "", fq: ["{!terms f=id}#{ids.join(',')}"])
    end
  end

  def set_limit
    @limit = default_limit_for_hightlights
  end

end

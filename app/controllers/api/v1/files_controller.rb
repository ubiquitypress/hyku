class API::V1::FilesController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :get_work

  def index
    file_ids = @work && @work['response']['docs'].first["file_set_ids_ssim"]
    if file_ids.present?
      @files = CatalogController.new.repository.search(q: '', fq: ["{!terms f=id}#{file_ids.join(',')}"])
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "Work with id of #{params[:work_id]} has no files attached to it")
    end
=begin
    files_doc = @work.try(:file_sets) && @work.file_sets.map(&:to_solr)
    work = {'response' => {} }
    if files_doc.present?
      work['response']['docs'] = files_doc
      @files = work
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "Work with id of #{params[:work_id]} has no files attached to it")
    end
=end
  end

  private

  def get_work
  #  @work = ActiveFedora::Base.find(params[:work_id])
    @work = CatalogController.new.repository.search(q: "id:#{params[:work_id]}")
  end

end

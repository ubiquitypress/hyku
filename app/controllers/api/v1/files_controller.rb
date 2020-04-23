class API::V1::FilesController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :get_work

  def index
    file_ids = @work && @work['response']['docs'].first["file_set_ids_ssim"]
    if file_ids.present?
      @files = CatalogController.new.repository.search(q: '', fq: ["{!terms f=id}#{file_ids.join(',')}"].concat(filter_using_visibility), rows: 100)
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "Work with id of #{params[:work_id]} has no files attached to it")
    end
  end

  private

  def get_work
    @work = CatalogController.new.repository.search(q: "id:#{params[:work_id]}")
  end

end

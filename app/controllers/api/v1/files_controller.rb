class API::V1::FilesController < API::V1::ApiBaseController 
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiCacheKeyGenerator

  before_action :get_work

  def index
    file_ids = @work.dig('response', 'docs', 0, "file_set_ids_ssim")
    if file_ids.present? && current_user.present?
      @files = CatalogController.new.repository.search(q: '', fq: ["{!terms f=id}#{file_ids.join(',')}"].concat(filter_using_visibility(current_user)), rows: 100, "sort" => "score desc, system_modified_dtsi desc")
    elsif file_ids.present?
      @files = CatalogController.new.repository.search(q: '', fq: ["{!terms f=id}#{file_ids.join(',')}"].concat(filter_using_visibility), rows: 100, "sort" => "score desc, system_modified_dtsi desc")
    else
      raise Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: "Work with id of #{params[:work_id]} has no files attached to it")
    end
  end

  private

  def get_work
    @work = CatalogController.new.repository.search(q: "id:#{params[:work_id]}")
  end

end

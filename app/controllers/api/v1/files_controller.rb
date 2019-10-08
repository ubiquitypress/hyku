class API::V1::FilesController < ActionController::Base
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers
  before_action :get_work

  def index
    files_doc = @work.try(:file_sets) && @work.file_sets.map(&:to_solr)
    work = {'response' => {} }
    if files_doc.present?
      work['response']['docs'] = files_doc
      @files = work
    else
      work['response']['docs'] = {message: 'No files found'}
      @files = work
    end
  end

  private

  def get_work
    @work = ActiveFedora::Base.find(params[:work_id])
  end

end

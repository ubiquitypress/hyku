
class API::V1::ReviewsController < API::V1::ApiBaseController
  include Ubiquity::ApiControllerUtilityMethods
  before_action :fetch_work

  def create
    object = ubiquity_api_work_flow_aproval_object
    if object.present? && object.is_valid_for_saving? && object.save

      render json: { data: ubiquity_api_work_flow_aproval_object.comments_on_work_for_review,
                  workflow_status: ubiquity_api_work_flow_aproval_object.workflow_state_name}
    else
      message = 'Unprocessable entity. It has one of the following issues. The user either has no permission to review a work or
       the work does not exists or the action name and comment were not sent back'
      error_object = Ubiquity::ApiError::NotFound.new(status: 422, code: 'Unprocessable entity', message: message)
      render json: error_object.error_hash
    end
  end

  private

  def get_permitted_params
    params.permit(:work_id, :name, :comment)
  end

  def fetch_work
    @work ||= ActiveFedora::Base.find(get_permitted_params[:work_id])
  end

  def ubiquity_api_work_flow_aproval_object
    if @work.present? && current_ability.present?
      @api_workflow_object ||= Ubiquity::ApiWorkflowApproval.new(ability: current_ability, account: current_account, work: @work,
        user: current_user, approval_action: get_permitted_params[:name], comment: get_permitted_params[:comment])
    end
  end

  def approval_object
    object = ubiquity_api_work_flow_aproval_object
    if object.present?
      object && object.hyrax_workflow_action_form_object
    end
  end

end

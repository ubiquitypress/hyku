# Called inside all_models_virtual_fields inside app/models/concerns
class AddWorkIdToExternalServiceJob < ActiveJob::Base #ApplicationJob
  queue_as :default

  def perform(work_id, draft_doi, tenant_name)
    AccountElevator.switch!(tenant_name)
    exter = ExternalService.where(draft_doi: draft_doi).first
    exter && exter.update(work_id: work_id)
  end
end

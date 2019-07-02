# Called inside all_models_virtual_fields inside app/models/concerns
class AddWorkIdToExternalServiceJob < ActiveJob::Base #ApplicationJob
  queue_as :default

  def perform(work_id, draft_doi, tenant_name)
    AccountElevator.switch!(tenant_name)
    puts"BOXING #{tenant_name.inspect}- work_id #{work_id.inspect} - draft_doi #{draft_doi.inspect}"
    exter = ExternalService.where(draft_doi: draft_doi).first
    puts"GYM #{exter.inspect}"

    exter && exter.update(work_id: work_id)
  end
end

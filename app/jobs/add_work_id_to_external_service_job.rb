# Called inside all_models_virtual_fields inside app/models/concerns
class AddWorkIdToExternalServiceJob < ActiveJob::Base #ApplicationJob
  queue_as :default

  def perform(work_id, tenant_name)
    AccountElevator.switch!(tenant_name)
    work = ActiveFedora::Base.find(work_id)
    exter = ExternalService.where(draft_doi: work.draft_doi).first
    puts "NOTEBOOK #{exter}"
    if work.present? && exter.try(:work_id).present?
      exter.update(work_id: work.id)
    end
  end
end

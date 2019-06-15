class UbiquityFileFacetDoiJob < ActiveJob::Base
  queue_as :default

  def perform(work_id, tenant_name)
    AccountElevator.switch!(tenant_name)
    work = ActiveFedora::Base.find(work_id)
    puts"OUTSIDE"
    if work.present? && work.official_link.present? && official_link_check?(work)
      puts"INSIDE IT"
         work.file_availability = work.file_availability | ["External link (access may be restricted)"]
      work.save
    else
      work.file_availability = ['File not available']
      work.save
    end
  end

  private

  def official_link_check?(work)
    if work.official_link.present?
      kk = ExternalService.where(draft_doi: work.draft_doi).first
      return true if kk.blank?
      return false if kk.present?
    end
  end

end

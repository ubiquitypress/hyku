class UbiquityFileFacetDoiJob < ActiveJob::Base
  queue_as :default

  def perform(work_id, tenant_name)
    AccountElevator.switch!(tenant_name)
    work = ActiveFedora::Base.find(work_id)
    puts"OUTSIDE"
    if work.present? && work.file_sets.blank? && work.doi.present?
      puts"INSIDE IT"
      work.file_availability = ["external_link"]
      work.save
    end
  end

end

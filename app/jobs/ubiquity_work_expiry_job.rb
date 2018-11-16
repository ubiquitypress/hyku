class UbiquityWorkExpiryJob < ActiveJob::Base
  def perform(work_id, work_class,  type, tenant)
    AccountElevator.switch!("#{tenant}")
    work = fetch_work(work_id, work_class)
    if work.present? && type == "embargo"
      Hyrax::Actors::EmbargoActor.new(work).destroy
    elsif work.present? && type == 'lease'
      Hyrax::Actors::LeaseActor.new(work).destroy
    end
  end

  private

  def fetch_work(work_id, work_class)
    if work_class.present? && work_id.present?
      work_class.find(work_id)
    end
  end
end

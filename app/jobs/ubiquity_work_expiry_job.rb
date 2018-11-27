class UbiquityWorkExpiryJob < ActiveJob::Base
  def perform(work_id, work_class,  type, tenant)
    AccountElevator.switch!("#{tenant}")
    @works = fetch_work(work_id, work_class)
    if @works.present? && type == "embargo"
      auto_expire_embargo
    elsif @works.present? && type == 'lease'
      auto_expire_lease
    end
  end

  private

  def fetch_work(work_id, work_class)
    if work_class.present? && work_id.present?
      work_class.constantize.where(id: work_id)
    end
  end

  def auto_expire_embargo
    @works.each do |work|
      puts "expiring work embargo #{work}"
      Hyrax::Actors::EmbargoActor.new(work).destroy
    end
  end

  def auto_expire_lease
    @works.each do |work|
      puts "expiring work lease #{work}"
      Hyrax::Actors::LeaseActor.new(work).destroy
    end
  end

end

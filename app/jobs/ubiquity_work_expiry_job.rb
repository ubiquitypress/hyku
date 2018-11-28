class UbiquityWorkExpiryJob < ActiveJob::Base
  #adds get_visibility_after_expiration and compare_visibility_after_expiration?
  include Ubiquity::ExpiryUtil
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
      #compare_visibility_after_expiration?(work, 'embargo')
      puts "expiring work embargo #{work}"
      if work.embargo_release_date.present?
        puts "embargo work with date #{work}"
        Hyrax::Actors::EmbargoActor.new(work).destroy
      elsif (not work.embargo_release_date.present?) && compare_visibility_after_expiration?(work, 'embargo')
        puts "work with no embargo date #{work}"
        work.visibility = get_visibility_after_expiration(work, 'embargo')
        work.save if work.visibility.present?
      end
    end
  end

  def auto_expire_lease
    @works.each do |work|
      puts "expiring work lease #{work}"
      if (work.lease_expiration_date.present?)
        puts "lease work with date #{work}"
        Hyrax::Actors::LeaseActor.new(work).destroy
      elsif (not work.lease_expiration_date.present?) && compare_visibility_after_expiration?(work, 'lease')
        puts "work with no lease date #{work}"
        work.visibility = get_visibility_after_expiration(work, 'lease')
        work.save if work.visibility.present?
      end
    end
  end

end

class UbiquityFileExpiryJob < ActiveJob::Base
  queue_as :expiry_service
  #adds get_visibility_after_expiration and compare_visibility_after_expiration?
  include Ubiquity::ExpiryUtil

  def perform(file_set_id, type, tenant)
    AccountElevator.switch!("#{tenant}")
    @file_sets = fetch_fileset(file_set_id)
    if @file_sets.present? && type == "embargo"
      auto_expire_embargo
    elsif @file_sets.present? && type == 'lease'
      auto_expire_lease
    end
  end

 private

  def fetch_fileset(file_set_id)
    if file_set_id.present?
      FileSet.where(id: file_set_id)
    end
  end

  def auto_expire_embargo
    @file_sets.each do |file_set|
      puts "expiring fileset embargo #{file_set}"
      if file_set.embargo_release_date.present?
        puts "embargo file_set with date #{file_set}"
        Ubiquity::FileEmbargoActor.new(file_set).destroy
      elsif (not file_set.embargo_release_date.present?) && compare_visibility_after_expiration?(file_set, 'embargo')
        puts "file_set with no embargo date #{file_set}"
        file_set.visibility = get_visibility_after_expiration(file_set, 'embargo')
        file_set.save if file_set.visibility.present?
      end
    end
  end

  def auto_expire_lease
    @file_sets.each do |file_set|
      puts "expiring fileset lease #{file_set}"
      if (file_set.lease_expiration_date.present?)
        puts "lease file_set with date #{file_set}"
        Ubiquity::FileLeaseActor.new(file_set).destroy
      elsif (not file_set.lease_expiration_date.present?) && compare_visibility_after_expiration?(file_set, 'lease')
        puts "file_set with no lease date #{file_set}"
        file_set.visibility = get_visibility_after_expiration(file_set, 'lease')
        file_set.save if file_set.visibility.present?
      end
    end
  end

end

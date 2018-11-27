class UbiquityFileExpiryJob < ActiveJob::Base
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
    @file_sets.each do |work|
      puts "expiring fileset embargo #{work}"
      Ubiquity::FileEmbargoActor.new(file_set).destroy
    end
  end

  def auto_expire_lease
    @file_sets.each do |work|
      puts "expiring fileset lease #{work}"
      Ubiquity::FileLeaseActor.new(file_set).destroy
    end
  end

end

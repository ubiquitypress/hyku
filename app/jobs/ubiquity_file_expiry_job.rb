class UbiquityFileExpiryJob < ActiveJob::Base
  def perform(file_set_id, type, tenant)
    AccountElevator.switch!("#{tenant}")
    file_set = fetch_fileset(file_set_id)
    if file_set.present? && type == "embargo"
      Ubiquity::FileEmbargoActor.new(file_set).destroy
    elsif file_set.present? && type == 'lease'
      Ubiquity::FileLeaseActor.new(file_set).destroy
    end
  end

 private

  def fetch_fileset(file_set_id)
    if file_set_id.present?
      FileSet.find(file_set_id)
    end
  end

end

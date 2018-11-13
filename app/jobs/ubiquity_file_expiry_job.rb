class UbiquityFileExpiryJob < ActiveJob::Base
  def perform(file_set, type, tenant)
    AccountElevator.switch!("#{tenant}")
    if type == "embargo"
     Ubiquity::FileEmbargoActor.new(file_set).destroy
   else
     Ubiquity::FileLeaseActor.new(file_set).destroy
   end
  end

end

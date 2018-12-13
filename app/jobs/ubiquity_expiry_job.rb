class UbiquityExpiryJob < ActiveJob::Base
  queue_as :expiry_service
  def perform
    service = Ubiquity::ExpiryService.new
    service.release_embargo!
    service.release_lease!
    service.release_embargo_on_files!
    service.release_lease_on_files!
  end
end

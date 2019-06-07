class UbiquityExpiryJob < ActiveJob::Base
  queue_as :expiry_service
  def perform
    Ubiquity::ExpiryService.new.release_expired_works
  end
end

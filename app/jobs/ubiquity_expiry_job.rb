class UbiquityExpiryJob < ActiveJob::Base
  def perform
    service = Ubiquity::ExpiryService.new
    service.release_embargo!.release_lease!
    service.release_embargo_on_files!
    service.release_lease_on_files!
  rescue ActiveFedora::ObjectNotFoundError
    puts "bexit work ExpiryJob"
  
  end
end

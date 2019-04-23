class UbiquityPostToIndexerJob < ActiveJob::Base
  def perform(work_uuid)
    Ubiquity::IndexerClient.new(work_uuid).post
  end
end  

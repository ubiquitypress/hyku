class UbiquityPostToIndexerJob < ActiveJob::Base
  def perform(work_uuid, draft_doi, tenant_name)
    Ubiquity::IndexerClient.new(work_uuid, draft_doi, tenant_name).post
  end
end

class UbiquityPostFileToImporterJob < ActiveJob::Base
  #queue_as :default
  def perform(file_set_uuid, tenant_uuid)
    importer_instance = Ubiquity::ImporterClient.new()
    importer_instance.post_to_importer(file_set_uuid, tenant_uuid)
  end
end

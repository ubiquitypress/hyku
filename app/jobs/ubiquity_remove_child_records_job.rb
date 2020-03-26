class UbiquityRemoveChildRecordsJob < ActiveJob::Base
  def perform(collection_id, collection_name, tenant_name)
    AccountElevator.switch!(tenant_name)
    RemoveChildRecords.remove_member_objects_from_solr_only(collection_id, collection_name)
  end 
end

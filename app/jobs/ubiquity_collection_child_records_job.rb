class UbiquityCollectionChildRecordsJob < ActiveJob::Base
  def perform(collection_id: , collection_name: , tenant_name:, work_id: nil,  type: )
    AccountElevator.switch!(tenant_name)
    if type == 'remove'
      Ubiquity::ManageCollectionChildRecords.remove_member_objects_from_solr_only(collection_id, collection_name)
    elsif type == "update"
      Ubiquity::ManageCollectionChildRecords.update_work_collection_names_after_update(collection_id, collection_name)
    elsif type == "add"
      Ubiquity::ManageCollectionChildRecords.add_work_to_collection(work_id, collection_id)
    end
  end
end

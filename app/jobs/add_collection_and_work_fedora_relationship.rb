class AddCollectionAndWorkFedoraRelationship < ActiveJob::Base
  queue_as :default

  def perform(work_id, collection_id, tenant_name)
    AccountElevator.switch!(tenant_name)
    collection = ActiveFedora::Base.find(collection_id)
    work = ActiveFedora::Base.find(work_id)
    #move the line below to a background job
    work.member_of_collections << collection
    work.save
  end

end

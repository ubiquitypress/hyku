#overriding or adding methods in https://github.com/samvera/hyrax/blob/v2.0.2/app/models/concerns/hyrax/collection_behavior.rb
#used in https://github.com/samvera/hyrax/blob/v2.0.2/app/controllers/hyrax/dashboard/collections_controller.rb
#
module Ubiquity
  module CollectionBehaviourOverride
    extend ActiveSupport::Concern

    included do
      before_destroy :remove_collection_id_from_works
    end

    def member_objects
      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id} OR collection_id_sim:#{id}")
    end

    # Add member objects by adding this collection to the objects' member_of_collection association.
    def add_member_objects(new_member_ids)
      Array(new_member_ids).each do |member_id|
        member = ActiveFedora::Base.find(member_id)
        member.member_of_collections << self
        member.save!
       end
     end
     #use by ubiquitypress to add collection id to works without using fedora association
     def add_member_objects_to_solr_only(new_member_ids)
       UbiquityCollectionChildRecordsJob.perform_later(collection_id: self.id, collection_name: self.title.try(:first), tenant_name: self.account_cname, work_id: new_member_ids, type: 'add')
     end

     private

     def remove_collection_id_from_works
       UbiquityCollectionChildRecordsJob.perform_now(collection_id: self.id, collection_name: self.title.try(:first), tenant_name: self.account_cname, type: 'remove')
     end

  end
end

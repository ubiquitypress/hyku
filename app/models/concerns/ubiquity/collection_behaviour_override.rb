#overriding or adding methods in https://github.com/samvera/hyrax/blob/v2.0.2/app/models/concerns/hyrax/collection_behavior.rb
#used in https://github.com/samvera/hyrax/blob/v2.0.2/app/controllers/hyrax/dashboard/collections_controller.rb
#
module Ubiquity
  module CollectionBehaviourOverride
    include ActiveSupport::Concern

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
     Array(new_member_ids).each do |member_id|
       member = ActiveFedora::Base.find(member_id)
       member.collection_id = ([self.id] | member.collection_id.to_a )
       member.collection_names =  ([self.title.first] | member.collection_names.to_a)
       member.save!
     end
   end

  end
end

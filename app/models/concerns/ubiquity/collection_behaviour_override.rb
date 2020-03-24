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
       Array(new_member_ids).each do |member_id|
         member = ActiveFedora::Base.find(member_id)
         member.collection_id = ([self.id] | member.collection_id.to_a )
         member.collection_names =  ([self.title.first] | member.collection_names.to_a)
         member.save!
       end
     end

     private

     def remove_collection_id_from_works
       remove_member_objects_from_solr_only(self)
     end

     def remove_member_objects_from_solr_only(collection)
       works =  ActiveFedora::Base.where("collection_id_sim:#{collection.id}")
       if works.present?
         works.each do |work|
           collection_id_array = work.collection_id.to_a - [collection.id]
           collection_names_array = work.collection_names.to_a - [collection.title.try(:first)]
           work.collection_id = collection_id_array
           work.collection_names = collection_names_array
           work.save!
         end
       end
     end


  end
end

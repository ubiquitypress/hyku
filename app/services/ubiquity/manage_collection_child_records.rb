module Ubiquity
  class ManageCollectionChildRecords

    def self.remove_member_objects_from_solr_only(collection_id, collection_name)
      works =  ActiveFedora::Base.where("collection_id_sim:#{collection_id}")
      if works.present?
        works.each do |work|
          collection_id_array = work.collection_id.to_a - [collection_id]
          collection_names_array = work.collection_names.to_a - [collection_name]
          work.collection_id = collection_id_array
          work.collection_names = collection_names_array
          work.save!
        end
      end
    end

    def self.update_work_collection_names_after_update(collection_id, old_collection_name)
      collection = Collection.find(collection_id)
      collection.member_objects.each do |member|
         original_array = member.collection_names.to_a
         original_array.delete(old_collection_name)
         member.collection_names = original_array | collection.title.to_a
         member.save
      end
      rescue ActiveFedora::ObjectNotFoundError
      $stdout.puts "collection with id #{collection.try(:id)} does not exist"
    end

  end
end

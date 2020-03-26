class RemoveChildRecords

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
  
end

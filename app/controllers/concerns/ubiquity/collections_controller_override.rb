#https://github.com/samvera/hyrax/blob/v2.0.2/app/controllers/concerns/hyrax/collections_controller_behavior.rb

module Ubiquity
  module CollectionsControllerOverride
    extend ActiveSupport::Concern

    private

    def add_members_to_collection(collection = nil)
      collection ||= @collection

      if check_should_not_use_fedora_association.present?
        #use by ubiquitypress to add collection id to works without using fedora association
        collection.add_member_objects_to_solr_only batch
      else
        collection.add_member_objects batch
      end
    end

    def remove_members_from_collection
      batch.each do |pid|
        work = ActiveFedora::Base.find(pid)
        work.member_of_collections.delete @collection
        #added by ubiquity to remove works in siuations where we are not using fedora association between collection and works
        collection_id_array = work.collection_id.to_a - [@collection.id]
        collection_names_array = work.collection_names.to_a - [@collection.title.try(:first)]
        work.collection_id = collection_id_array
        work.collection_names = collection_names_array

        work.save!
      end
    end

    def move_members_between_collections
      destination_collection = ::Collection.find(params[:destination_collection_id])
      remove_members_from_collection
      add_members_to_collection(destination_collection)
      if destination_collection.save
        flash[:notice] = "Successfully moved #{batch.count} files to #{destination_collection.title} Collection."
      else
        flash[:error] = "An error occured. Files were not moved to #{destination_collection.title} Collection."
      end
    end

    def check_should_not_use_fedora_association
      tenant_work_settings_hash = Ubiquity::ParseTenantWorkSettings.new(request.original_url).tenant_work_settings_hash
      tenant_work_settings_hash && tenant_work_settings_hash["turn_off_fedora_collection_work_association"]
    end

  end
end

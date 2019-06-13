module Ubiquity
  module FileSetActorOverride
    include ActiveSupport::Concern

    def attach_to_work(work, file_set_params = {})
        acquire_lock_for(work.id) do
          # Ensure we have an up-to-date copy of the members association, so that we append to the end of the list.
          work.reload unless work.new_record?
          file_set.visibility = work.visibility unless assign_visibility?(file_set_params)
          work.ordered_members << file_set
          work.representative = file_set if work.representative_id.blank?
          work.thumbnail = file_set if work.thumbnail_id.blank?
          # Save the work so the association between the work and the file_set is persisted (head_id)
          # NOTE: the work may not be valid, in which case this save doesn't do anything.
          file_status = file_set.visibility == 'restricted' ? 'unavailable' : 'available'
          work.file_availability = [file_status]
          work.save
          Hyrax.config.callback.run(:after_create_fileset, file_set, user)
        end
    end

    private

    def unlink_from_work
       work = file_set.parent
       return unless work && (work.thumbnail_id == file_set.id || work.representative_id == file_set.id)
       # Must clear the thumbnail_id and representative_id fields on the work and force it to be re-solrized.
       # Although ActiveFedora clears the children nodes it leaves those fields in Solr populated.
       work.thumbnail = nil if work.thumbnail_id == file_set.id
       work.representative = nil if work.representative_id == file_set.id
       work.file_availability = []
       work.save!
    end

  end
end

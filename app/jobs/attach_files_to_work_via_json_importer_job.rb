#Subclasses https://raw.githubusercontent.com/samvera/hyrax/v2.0.2/app/jobs/attach_files_to_work_job.rb
# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkViaJsonImporterJob < AttachFilesToWorkJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files & visibility attribute - A hash containing
  #files to attach as value & the hash keys as visibility
  #[{:open => Hyrax::UploadedFile}, {:restricted => Hyrax::UploadedFile}, {'open' => Hyrax::UploadedFile}]
  #
  def perform(work, uploaded_files, **work_attributes)
    #validate_files!(uploaded_files)
    #added by me first implementation
    hyrax_uploaded_file_objects = uploaded_files.map {|h| h[:path]}
    validate_files!(hyrax_uploaded_file_objects)
    user = User.find_by_user_key(work.depositor) # BUG? file depositor ignored
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      #visibility must be set after attach_to_work is called otherwise
      #the work's visibility will override the visibility of the file in the json
      file_visibility_attributes = uploaded_file.with_indifferent_access.slice(:visibility,
                        :visibility_during_lease, :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo, :visibility_after_embargo)

      new_metadata = file_visibility_attributes.present? ? file_visibility_attributes : metadata
      actor.create_metadata(new_metadata)
      actor.create_content(uploaded_file.with_indifferent_access['path'])
      file_description = uploaded_file.with_indifferent_access['description']
      actor.file_set.description = [file_description] if file_description.present?
      actor.attach_to_work(work, new_metadata)
      actor.file_set.permissions_attributes = work_permissions
      #this job was created because the visibility attributes sent from the importer refused being set here
      add_file_visibility_attributes(actor.file_set, file_visibility_attributes)
      uploaded_file.update(file_set_uri: actor.file_set.uri)
    end
  end

  private

  def add_file_visibility_attributes(file_set, visibility_attributes)
    file_set.visibility = visibility_attributes[:visibility]
    file_set.embargo_release_date = visibility_attributes[:embargo_release_date]
    file_set.visibility_during_embargo = visibility_attributes[:visibility_during_embargo]
    file_set.visibility_after_embargo = visibility_attributes[:visibility_after_embargo]

    file_set.lease_expiration_date = visibility_attributes[:lease_expiration_date]
    file_set.visibility_during_lease = visibility_attributes[:visibility_during_lease]
    file_set.visibility_after_lease = visibility_attributes[:visibility_after_lease]
    #Re-saving because the visibility attributes sent from the importer refused being set without it
    file_set.save
  end


end

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
    validate_files!(uploaded_files.map {|h| h.values}.flatten)
    user = User.find_by_user_key(work.depositor) # BUG? file depositor ignored
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      actor.create_metadata(metadata)
      #actor.create_content(uploaded_file)
      actor.create_content(uploaded_file.values.first)
      actor.attach_to_work(work)
      actor.file_set.permissions_attributes = work_permissions
      #visibility must be set after attach_to_work is called otherwise
      #the work's visibility will override the visibility of the file in the json  
      actor.file_set.visibility = uploaded_file.keys.first
      uploaded_file.update(file_set_uri: actor.file_set.uri)
    end
  end

end

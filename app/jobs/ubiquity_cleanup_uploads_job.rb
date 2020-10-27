class UbiquityCleanupUploadsJob < ActiveJob::Base
  non_tenant_job

  def perform
    Account.all.each do |account|
      AccountElevator.switch!(account.cname)
      Rails.logger.debug("Running uploads cleanup on #{account.cname}")
      Hyrax::UploadedFile.where.not(file_set_uri: nil).each do |upload|
        next unless upload.file.file.exists?
        begin
          disk_checksum = Digest::SHA1.file upload.file.path
          fedora_checksum = FileSet.find(upload.file_set_uri.split('/').last).original_file.checksum.value
          File.delete(upload.file.path) if (disk_checksum == fedora_checksum) && (upload.updated_at < Time.now.utc - 7.days)
        rescue Exception => e
          # TODO: handle specific errors like Ldp::Gone where it should be safe to delete the uploaded file
          Rails.logger.error("Error verifying checksum or removing file (#{upload.file.path}): #{e.to_s}")
        end
      end
    end
  end
end

namespace :file_upload do
  desc "Task to update the newly added column `file_status` to 1 for the existing records"
  task :update_file_status_column, [:name] => :environment do |_task, tenant|
    AccountElevator.switch!(tenant[:name].to_s)
    Hyrax::UploadedFile.where(file_status: 0).each do |uploaded_file|
      file_upload = uploaded_file.update_attribute(:file_status, 1)
      if file_upload
        puts 'file_status column has been updated for the record id : ' + uploaded_file.id.to_s
      else
        puts 'An error has been occured : ' + file_upload.errors.full_messages
      end
    end
  end
end

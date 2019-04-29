module Ubiquity
  module UploadsControllerOverride
    include ActiveSupport::Concern

    def create
      # Replace all the non characters to underscore except - and  .
      file_name = params[:files].first.original_filename.gsub(/[^a-zA-Z0-9\-.]/, '_')
      @upload = Hyrax::UploadedFile.where(file: file_name, user_id: current_user.id, file_status: 'pending').first
      if @upload.nil?
        @upload = Hyrax::UploadedFile.create(file: params[:files].first, user_id: current_user.id)
      elsif @upload.file_status == 'pending'
        path = @upload.file.path
        File.open(path, "ab") { |f| f.write(params[:files].first.read) }
      end
    end
  end
end

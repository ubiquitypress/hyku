module Ubiquity
  class FailUploadsController < ApplicationController
    def delete_file
      file_name = params[:file_upload][:filename].gsub(/[^a-zA-Z0-9\-.]/, '_')
      failed_upload = Hyrax::UploadedFile.where(file: file_name, user_id: current_user.id, file_status: 'pending').first
      if failed_upload
        failed_upload.destroy
      end
    end

    private

      def uploaded_file_params
        params.require(:file_upload).permit(:filename, :user_id, :file_status)
      end
  end
end

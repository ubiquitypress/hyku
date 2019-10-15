module Ubiquity
  class FailUploadsController < ApplicationController
    def delete_file
      file_name = params[:file_upload][:filename].gsub(/[^a-zA-Z0-9\-.]/, '_')
      failed_upload = Hyrax::UploadedFile.where(file: file_name, user_id: current_user.id, file_status: 0).first
      if failed_upload
        failed_upload.destroy
      end
    end

    def download_file
      file_uuid = params[:fileset_id]
      s3_file_set_url = Ubiquity::ImporterClient.get_s3_url file_uuid
      url = s3_file_set_url.file_url_hash[params[:fileset_id]]
      redirect_to url
    end

    private

      def uploaded_file_params
        params.require(:file_upload).permit(:filename, :user_id, :file_status)
      end
  end
end

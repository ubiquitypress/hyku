module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    def create
      # Replace all the non characters to underscore except - and  .
      file_name = params[:files].first.original_filename.gsub(/[^a-zA-Z0-9\-.]/, '_')
      @upload = Hyrax::UploadedFile.where(file: file_name, user_id: current_user.id, file_status: 0).first
      if @upload.nil?
        @upload = Hyrax::UploadedFile.create(file: params[:files].first, user_id: current_user.id)
      elsif @upload.file_status.zero?
        path = @upload.file.path
        File.open(path, "ab") { |f| f.write(params[:files].first.read) }
      end
    end

    def destroy
      @upload.destroy
      head :no_content
    end
  end
end

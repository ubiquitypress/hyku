module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    def create
      @upload = Hyrax::UploadedFile.where(file: params[:files].first.original_filename, user_id: current_user.id).first
      if @upload.nil?
        @upload = Hyrax::UploadedFile.create(file: params[:files].first, user_id: current_user.id)
      else
        path = @upload.file.path
        File.open(path, "ab") { |f| f.write(params[:files].first.read) }
      end
      @upload.save
    end

    def destroy
      @upload.destroy
      head :no_content
    end
  end
end

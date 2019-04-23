module Ubiquity
  module FileUploadCallback
    extend ActiveSupport::Concern
    included do
      # For updating the file status column which is uploade by large file chunks
      after_commit :set_file_status
    end

    private

      def set_file_status
        update_column(:file_status, 1) unless file_set_uri.nil?
      end
  end
end

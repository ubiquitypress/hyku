require 'hyrax'
module Hyrax
  class UploadedFile < ActiveRecord::Base
    after_commit :set_file_status

    private
    def set_file_status
      self.update_column(:file_status, 1) unless file_set_uri.nil?
    end
  end
end
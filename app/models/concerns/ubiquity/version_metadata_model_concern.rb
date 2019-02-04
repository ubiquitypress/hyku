#Included in any work that requires saving version number. Currently used in Dataset and GenericWork
module Ubiquity
  module VersionMetadataModelConcern
    extend ActiveSupport::Concern
    include Ubiquity::AllModelsVirtualFields

    included do
      before_save :save_version
    end

    private

    def save_version
      self.version = self.version_number
    end

  end
end

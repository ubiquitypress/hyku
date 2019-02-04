module Ubiquity
  module VersionMetadataFormBehaviour
    extend ActiveSupport::Concern

    included do
      attr_accessor :version_number
    end

    class_methods do
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << {version_number: []}
        end
      end
    end

  end
end

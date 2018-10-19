module Ubiquity
  module EditorMetadataFormBehaviour
    extend ActiveSupport::Concern

    included do
      attr_accessor :editor_group, :editor_name_type, :editor_given_name,
                      :editor_family_name, :editor_orcid, :editor_isni,
                      :editor_position, :editor_organization_name, :editor_institutional_relationship
    end

    class_methods do
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << {editor: []}
          permitted_params << {editor_group: [:editor_given_name,
            :editor_family_name, :editor_name_type, :editor_orcid, :editor_isni,
            :editor_position, :editor_organization_name, :editor_institutional_relationship => []
          ]}
        end
      end
    end

  end
end

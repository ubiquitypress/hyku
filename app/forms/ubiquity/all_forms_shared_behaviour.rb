module Ubiquity
  module AllFormsSharedBehaviour
    extend ActiveSupport::Concern

    included do
      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                    :contributor_family_name, :contributor_orcid, :contributor_isni,
                    :contributor_position, :contributor_organization_name

      attr_accessor :creator_group, :creator_name_type, :creator_organization_name, :creator_given_name,
                    :creator_family_name, :creator_orcid, :creator_isni,
                    :creator_position

      attr_accessor :alternate_identifier_group, :related_identifier_group
      self.terms += %i[alternate_identifier related_identifier]

    end

    class_methods do
      def multiple?(field)
        if [:title].include? field.to_sym
          false
        else
          super
        end
      end

      def model_attributes(_)
        attrs = super
        attrs[:title] = Array(attrs[:title]) if attrs[:title]
        attrs
      end

      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << {contributor_group: [:contributor_organization_name, :contributor_given_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni,
            :contributor_position, :contributor_type
          ]}

          permitted_params << {creator_group: [:creator_organization_name, :creator_given_name,
            :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni,
            :creator_position
          ]}

          permitted_params << { alternate_identifier_group: %i[alternate_identifier alternate_identifier_type] }

          permitted_params << { related_identifier_group: %i[related_identifier related_identifier_type relation_type] }

        end
      end
    end # closes class class_methods

    # instance methods
    def title
      super.first || ""
    end

  end
end

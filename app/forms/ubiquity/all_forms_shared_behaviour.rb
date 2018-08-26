module Ubiquity
  module AllFormsSharedBehaviour
    extend ActiveSupport::Concern

    included do

      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                  :contributor_family_name, :contributor_orcid, :contributor_isni,
                  :contributor_position

      attr_accessor :creator_group, :creator_name_type, :creator_name, :creator_given_name,
                    :creator_family_name, :creator_orcid, :creator_isni,
                    :creator_position

    end

    class_methods do

      def build_permitted_params

        super.tap do |permitted_params|
          permitted_params << { contributor_given_name: []}
          permitted_params << {contributor_type: []}
          permitted_params << {contributor_orcid: []}
          permitted_params <<  {contributor_name_type: []}
          permitted_params << {contributor_family_name: [] }
          permitted_params << {contributor_isni: []}
          permitted_params << :contributor_position
          permitted_params << {contributor_group: [:contributor_name, :contributor_given_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni,
            :contributor_position
          ]}

          permitted_params << {creator_name: []}
          permitted_params << { creator_given_name: []}
          permitted_params << {creator_family_name: [] }
          permitted_params << {creator_orcid: []}
          permitted_params <<  {creator_name_type: []}
          permitted_params << {creator_isni: []}

          permitted_params << :creator_position

          permitted_params << {creator_group: [:creator_name, :creator_given_name,
            :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni,
            :creator_position
          ]}
      end

      end
    end

  end
end

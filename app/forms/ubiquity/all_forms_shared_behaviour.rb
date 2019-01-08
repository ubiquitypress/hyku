module Ubiquity
  module AllFormsSharedBehaviour
    extend ActiveSupport::Concern

    included do
      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                    :contributor_family_name, :contributor_orcid, :contributor_isni,
                    :contributor_position, :contributor_organization_name,
                    :contributor_institutional_relationship

      attr_accessor :creator_group, :creator_name_type, :creator_organization_name, :creator_given_name,
                    :creator_family_name, :creator_orcid, :creator_isni,
                    :creator_position, :creator_institutional_relationship

      attr_accessor :alternate_identifier_group, :related_identifier_group,
                    :date_published_group, :date_accepted_group, :date_submitted_group,
                    :event_date, :related_exhibition_date

      attr_accessor :note

      # terms inherited from Hyrax::Forms::WorkForm are removed
      # to then be added at the desired position in each work type form (ex `article_form`)
      self.terms -= %i[title
                       creator
                       contributor
                       description
                       keyword
                       license
                       rights_statement
                       publisher
                       date_created
                       subject
                       language
                       identifier
                       based_near
                       related_url
                       source]

      self.required_fields -= %i[title creator keyword rights_statement]
      # `title` and `creator` to be removed first then inserted in the desired order
      self.required_fields += %i[title resource_type creator institution date_published]
    end

    class_methods do

      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << {contributor_group: [:contributor_organization_name, :contributor_given_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni,
            :contributor_position, :contributor_type, :contributor_institutional_relationship => []
          ]}

          permitted_params << {creator_group: [:creator_organization_name, :creator_given_name,
            :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni,
            :creator_position, :creator_institutional_relationship => []
          ]}

          permitted_params << { alternate_identifier_group: %i[alternate_identifier alternate_identifier_type] }

          permitted_params << { related_identifier_group: %i[related_identifier related_identifier_type relation_type] }

          permitted_params << { date_published_group: %i[date_published_year date_published_month date_published_day] }
          permitted_params << { date_accepted_group: %i[date_accepted_year date_accepted_month date_accepted_day] }
          permitted_params << { date_submitted_group: %i[date_submitted_year date_submitted_month date_submitted_day] }
          permitted_params << { event_date_group: %i[event_date_year event_date_month event_date_day] }
          permitted_params << { related_exhibition_date_group: %i[related_exhibition_date_year
                                                                  related_exhibition_date_month
                                                                  related_exhibition_date_day] }
        end
      end
    end # closes class class_methods

    # instance methods
    def title
      super.first || ""
    end
  end
end

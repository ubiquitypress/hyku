# Generated via
#  `rails generate hyrax:work TimeBasedMedia`
module Hyrax
  class TimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour
    include Ubiquity::VersionMetadataFormBehaviour

    self.model_class = ::TimeBasedMedia
    include HydraEditor::Form::Permissions

    self.terms += %i[title alt_title resource_type creator contributor rendering_ids abstract date_published media duration
                     institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                     editor version_number
                     publisher place_of_publication date_accepted date_submitted official_link
                     related_url related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                     rights_holder doi draft_doi alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end

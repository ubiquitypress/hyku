module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ConferenceItem
    self.terms += %i[title resource_type creator contributor rendering_ids doi alternate_identifier
                     related_identifier event_title event_date event_location book_title series_name volume editor
                     publisher place_of_publication pagination isbn issn eissn date_published
                     date_accepted date_submitted abstract keyword library_of_congress_classification
                     institution org_unit refereed official_link related_url project_name funder fndr_project_ref
                     language license rights_statement rights_holder add_info]
  end
end

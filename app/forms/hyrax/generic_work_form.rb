# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour
    include Ubiquity::VersionMetadataFormBehaviour


    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions

    #version is used in the show page but populated by version_number from the edit and new form
    self.terms += %i[title alt_title resource_type creator contributor rendering_ids abstract date_published media duration
                     institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                     series_name book_title editor journal_title alternative_journal_title volume edition version_number issue pagination article_num
                     publisher place_of_publication isbn issn eissn current_he_institution date_accepted date_submitted official_link
                     related_url related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                     rights_holder doi qualification_name qualification_level draft_doi alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end

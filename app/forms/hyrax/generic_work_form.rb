# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[title resource_type creator contributor rendering_ids doi alternate_identifier
                     version related_identifier series_name volume edition journal_title issue pagination
                     editor publisher place_of_publication isbn issn eissn article_num media
                     date_published date_accepted date_submitted abstract keyword institution org_unit
                     refereed official_link related_url related_exhibition related_exhibition_date project_name
                     funder fndr_project_ref add_info language license rights_statement rights_holder]
  end
end

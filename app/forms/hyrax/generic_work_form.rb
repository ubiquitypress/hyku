# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[resource_type rendering_ids doi series_name edition journal_title volume issue pagination
                     place_of_publication isbn issn eissn article_num date_published date_accepted date_submitted
                     abstract institution org_unit official_link project_name funder fndr_project_ref add_info
                     rights_holder]
    self.terms -= %i[based_near description source]
    self.required_fields += %i[journal_title institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

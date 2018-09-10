module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ConferenceItem
    self.terms += %i[resource_type rendering_ids doi event_title event_date book_title series_name volume pagination
                     place_of_publication issn eissn date_published date_accepted date_submitted abstract institution
                     org_unit refereed official_link project_name funder fndr_project_ref add_info rights_holder]
    self.terms -= %i[based_near description source subject]
    self.required_fields += %i[resource_type institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

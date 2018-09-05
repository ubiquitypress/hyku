# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::Report
    self.terms += %i[resource_type rendering_ids doi series_name volume edition pagination place_of_publication
                     issn eissn date_published date_accepted date_submitted abstract institution org_unit refereed
                     official_link project_name funder fndr_project_ref add_info rights_holder]
    self.terms -= %i[based_near description]
    self.required_fields += %i[resource_type institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

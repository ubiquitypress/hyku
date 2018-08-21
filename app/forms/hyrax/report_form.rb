# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Report
    self.terms += %i[resource_type rendering_ids doi series_name volume edition pagination place_of_publication
                     issn eissn date_published date_accepted date_submitted institution org_unit refereed
                     project_name funder fndr_project_ref add_info rights_holder]
    self.terms -= [:based_near]
    self.required_fields += %i[institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

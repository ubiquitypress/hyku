# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  class BookContributionForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    
    self.model_class = ::BookContribution
    self.terms += %i[resource_type rendering_ids doi series_name volume edition place_of_publication pagination
                     issn eissn date_published date_accepted date_submitted abstract institution org_unit refereed
                     project_name funder fndr_project_ref add_info rights_holder]
    self.terms -= %i[based_near description]
    self.required_fields += %i[resource_type institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

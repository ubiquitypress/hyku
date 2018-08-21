# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Book
    self.terms += %i[resource_type rendering_ids doi series_name volume pagination issn eissn
                     date_published date_accepted date_submitted institution org_unit refereed
                     project_name funder fndr_project_ref add_info rights_holder]
    self.required_fields += %i[institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

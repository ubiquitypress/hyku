# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Image
    self.terms += %i[resource_type rendering_ids doi place_of_publication date_published date_accepted
                     date_submitted abstract media institution org_unit official_link related_exhibition
                     related_exhibition_date project_name funder fndr_project_ref add_info rights_holder]
    self.terms -= %i[based_near description source subject]
    self.required_fields += %i[resource_type institution publisher date_published]
    self.required_fields -= %i[keyword rights_statement]
  end
end

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Image
    self.terms += %i[title resource_type creator contributor rendering_ids doi alternate_identifier
                     related_identifier publisher place_of_publication date_published date_accepted
                     date_submitted abstract keyword library_of_congress_classification media institution org_unit
                     official_link related_url related_exhibition related_exhibition_date project_name
                     funder fndr_project_ref language license rights_statement rights_holder add_info]
  end
end

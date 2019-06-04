# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Image
    self.terms += %i[title alt_title resource_type creator contributor abstract date_published media institution
                     org_unit project_name funder fndr_project_ref publisher place_of_publication date_accepted
                     date_submitted official_link related_url related_exhibition related_exhibition_date language
                     license rights_statement rights_holder doi draft_doi alternate_identifier related_identifier
                     rendering_ids keyword library_of_congress_classification add_info
                    ]
  end
end

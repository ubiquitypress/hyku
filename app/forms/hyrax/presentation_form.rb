# Generated via
#  `rails generate hyrax:work Presentation`
module Hyrax
  class PresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::Presentation
    self.required_fields += %i[org_unit]
    self.remove_required_from_primary += %i[org_unit]

    self.terms += %i[title alt_title resource_type creator contributor abstract
                     date_published pagination is_included_in volume publisher issn additional_links rights_holder license
                     org_unit doi subject keyword refereed add_info
                    ]
  end
end

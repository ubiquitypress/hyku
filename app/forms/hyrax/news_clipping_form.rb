# Generated via
#  `rails generate hyrax:work NewsClipping`
module Hyrax
  class NewsClippingForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::NewsClipping

    self.required_fields += %i[]
    self.remove_required_from_primary += %i[]

    self.terms += %i[title alt_title resource_type creator contributor abstract
                     date_published challenged location outcome partecipant reading_level pagination additional_links
                     rights_holder license doi subject keyword add_info
                    ]


  end
end

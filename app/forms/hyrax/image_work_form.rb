# Generated via
#  `rails generate hyrax:work ImageWork`
module Hyrax
  class ImageWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ImageWork
    self.required_fields += %i[org_unit]
    self.remove_required_from_primary += %i[org_unit]

    self.terms += %i[title alt_title resource_type creator contributor abstract date_published
                    publisher additional_links
                    rights_holder license org_unit doi subject keyword add_info
                  ]


  end
end

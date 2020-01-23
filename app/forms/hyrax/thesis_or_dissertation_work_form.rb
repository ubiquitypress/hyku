# Generated via
#  `rails generate hyrax:work ThesisOrDissertationWork`
module Hyrax
  class ThesisOrDissertationWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ThesisOrDissertationWork
    self.required_fields += %i[org_unit]
    self.remove_required_from_primary += %i[org_unit]

    self.terms += %i[title alt_title resource_type creator contributor abstract date_published
                      pagination is_included_in publisher additional_links
                      rights_holder license doi degree org_unit doi subject keyword add_info
                    ]

  end
end

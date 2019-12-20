# Generated via
#  `rails generate hyrax:work Uncategorized`
module Hyrax
  class UncategorizedForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::Uncategorized

    self.required_fields += %i[org_unit refereed]
    self.remove_required_from_primary += %i[org_unit refereed]

    self.terms += %i[title alt_title resource_type creator contributor abstract
                     date_published duration version_number pagination volume issue journal_title publisher issn additional_links rights_holder license
                     doi degree org_unit subject keyword refereed irb_status irb_number add_info
                    ]
  end
end

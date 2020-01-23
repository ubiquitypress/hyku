# Generated via
#  `rails generate hyrax:work BookWork`
module Hyrax
  class BookWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::BookWork
    self.required_fields += %i[org_unit pagination publisher]
    self.remove_required_from_primary += %i[org_unit pagination publisher]

    self.terms += %i[title alt_title resource_type creator contributor abstract date_published
                      pagination volume buy_book publisher isbn issn additional_links
                      rights_holder license org_unit doi subject keyword refereed add_info
                    ]
  end
end

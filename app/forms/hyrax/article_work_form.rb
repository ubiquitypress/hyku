# Generated via
#  `rails generate hyrax:work ArticleWork`
module Hyrax
  class ArticleWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ArticleWork
    self.required_fields += %i[org_unit]
    self.remove_required_from_primary += %i[org_unit]

    self.terms += %i[title alt_title resource_type creator contributor abstract date_published pagination issue
                     volume journal_title publisher issn source additional_links
                     rights_holder license org_unit doi subject keyword refereed
                     irb_status irb_number add_info
                    ]
  end
end

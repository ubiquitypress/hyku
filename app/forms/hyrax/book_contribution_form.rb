# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  class BookContributionForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::BookContribution
    self.terms += %i[title alt_title resource_type creator contributor date_published abstract institution
                     org_unit project_name funder fndr_project_ref series_name book_title editor
                     volume edition pagination publisher place_of_publication isbn issn eissn
                     date_accepted date_submitted official_link related_url language license
                     rights_statement rights_holder doi draft_doi alternate_identifier
                     related_identifier refereed keyword dewey library_of_congress_classification
                     add_info rendering_ids
                    ]
  end
end

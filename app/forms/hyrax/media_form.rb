# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour
    include Ubiquity::VersionMetadataFormBehaviour

    self.model_class = ::Media
    self.required_fields += %i[org_unit]
    self.remove_required_from_primary += %i[org_unit]

    self.terms += %i[title alt_title resource_type creator contributor abstract
                     date_published duration version_number book_title volume is_included_in
                    publisher issn additional_links rights_holder license
                     org_unit doi subject keyword refereed add_info
                    ]

    self.terms -= %i[book_title library_of_congress_classification related_identifier
                      alternate_identifier dewey series_name fndr_project_ref
                      funder project_name editor institution volume  issn
                    ]
  end
end

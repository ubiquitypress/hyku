# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Dataset
    #version is used in the show page but populated by version_number from the edit and new form
    self.terms += %i[title alt_title resource_type creator contributor abstract date_published institution
                     org_unit project_name funder fndr_project_ref version_number publisher place_of_publication
                     date_accepted date_submitted official_link related_url language license rights_statement
                     rights_holder doi draft_doi alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end

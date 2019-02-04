# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::Dataset
    #version is used in the show page but populated by version_number from the edit and new form
    self.terms += %i[title resource_type creator contributor rendering_ids doi alternate_identifier

                     version_number related_identifier publisher place_of_publication
                     date_published date_accepted date_submitted abstract keyword library_of_congress_classification
                     institution org_unit refereed official_link related_url project_name funder fndr_project_ref
                     language license rights_statement rights_holder add_info]
  end
end

# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`
module Hyrax
  class ThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour

    self.model_class = ::ThesisOrDissertation
    include HydraEditor::Form::Permissions

    self.terms += %i[title alt_title resource_type creator contributor rendering_ids abstract date_published media
                     institution org_unit project_name funder fndr_project_ref
                     pagination
                     publisher current_he_institution date_accepted date_submitted official_link
                     related_url language license rights_statement
                     rights_holder doi draft_doi qualification_name qualification_level alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end

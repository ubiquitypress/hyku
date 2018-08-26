# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[resource_type rendering_ids]
    self.required_fields += [:resource_type]
  end
end

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += [:resource_type, :rendering_ids]

    def secondary_terms
      super - [:rendering_ids]
    end

    # overrides Hyrax::Forms::WorkForm
    # to display 'license' in the 'base-terms' div on the user dashboard ‘Add New Work’ description
    # by getting iterated over in hyrax/app/views/hyrax/base/_form_metadata.html.erb
    def primary_terms
      super + [:license]
    end
  end
end

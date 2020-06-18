# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[resource_type]

    def tabs
      default_tabs = %w[metadata files relationships]
      default_tabs.prepend("doi") if Flipflop.doi_support?
      default_tabs
    end
  end
end

# Generated via
#  `rails generate hyrax:work Exhibition`
module Hyrax
  class ExhibitionForm < Hyrax::Forms::WorkForm
    self.model_class = ::Exhibition
    self.terms += [:resource_type]
  end
end

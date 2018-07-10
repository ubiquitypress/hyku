# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Dataset
    self.terms += [:resource_type]
  end
end

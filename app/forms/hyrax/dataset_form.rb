# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Dataset
    self.terms += %i[resource_type isni]
    def primary_terms
      super + [:isni]
    end
  end
end

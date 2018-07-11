# Generated via
#  `rails generate hyrax:work ConferencePaper`
module Hyrax
  class ConferencePaperForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::ConferencePaper
    self.terms += [:resource_type]
  end
end

# Generated via
#  `rails generate hyrax:work ConferencePaper`
module Hyrax
  class ConferencePaperForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::ConferencePaper
    self.terms += %i[resource_type rendering_ids]
  end
end

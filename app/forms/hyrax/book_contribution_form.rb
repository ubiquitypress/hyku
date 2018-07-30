# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  class BookContributionForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::BookContribution
    self.terms += %i[resource_type rendering_ids institution org_unit refereed]
  end
end

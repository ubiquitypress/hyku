# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Report
    self.terms += %i[resource_type rendering_ids institution org_unit]
  end
end

module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::ConferenceItem
    self.terms += %i[resource_type rendering_ids institution org_unit]
  end
end

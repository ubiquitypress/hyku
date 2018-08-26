# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    
    self.model_class = ::Image
    self.terms += %i[resource_type extent rendering_ids]
    self.required_fields += [:resource_type]
  end
end

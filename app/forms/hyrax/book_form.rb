# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Book
    self.terms += %i[resource_type rendering_ids]
  end
end

module Importer
  module Factory
    class BookFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Book
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Book')
      # end
    end
  end
end
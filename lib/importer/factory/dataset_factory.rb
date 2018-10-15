module Importer
  module Factory
    class DatasetFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Dataset
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Dataset')
      # end
    end
  end
end
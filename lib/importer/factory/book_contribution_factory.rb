module Importer
  module Factory
    class BookContributionFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = BookContribution
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'BookContribution')
      # end
    end
  end
end
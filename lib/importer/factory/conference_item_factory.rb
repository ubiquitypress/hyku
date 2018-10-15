module Importer
  module Factory
    class ConferenceItemFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ConferenceItem
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'ConferenceItem')
      # end
    end
  end
end
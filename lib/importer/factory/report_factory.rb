module Importer
  module Factory
    class ReportFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Report
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Report')
      # end
    end
  end
end
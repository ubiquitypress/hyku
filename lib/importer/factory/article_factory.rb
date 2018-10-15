module Importer
  module Factory
    class ArticleFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Article
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Article')
      # end
    end
  end
end
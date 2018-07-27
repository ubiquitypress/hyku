module Hyrax
  module BasicMetadataDecorator
    extend ActiveSupport::Concern

    included do
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable
      end

      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
        index.as :stored_searchable
      end
    end
  end
end
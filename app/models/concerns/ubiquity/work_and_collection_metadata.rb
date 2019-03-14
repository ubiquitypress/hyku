module Ubiquity
  module WorkAndCollectionMetadata
    extend ActiveSupport::Concern
    included do
      property :account_cname, predicate: ::RDF::Vocab::FOAF.account, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end

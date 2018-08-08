module SharedMetadata
  extend ActiveSupport::Concern
  # include here properties (fields) shared across a number of templates but not all
  # also see BasicMetadataDecorator
  included do
    property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
      index.as :stored_searchable
    end
    property :pagination, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false do |index|
      index.as :stored_searchable
    end
    property :issn, predicate: ::RDF::Vocab::BIBO.issn, multiple: false do |index|
      index.as :stored_searchable
    end
    property :eissn, predicate: ::RDF::Vocab::BIBO.eissn, multiple: false do |index|
      index.as :stored_searchable
    end
    property :official_link, predicate: ::RDF::Vocab::SCHEMA.url, multiple: false do |index|
      index.as :stored_searchable
    end
  end
end

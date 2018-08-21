module Ubiquity
module SharedMetadata
  extend ActiveSupport::Concern
  # include here properties (fields) shared across a number of templates but not all
  # also see BasicMetadataDecorator
  included do
    property :volume, predicate: ::RDF::Vocab::BIBO.volume do |index|
      index.as :stored_searchable
    end
    property :pagination, predicate: ::RDF::Vocab::BIBO.numPages do |index|
      index.as :stored_searchable
    end
    property :issn, predicate: ::RDF::Vocab::BIBO.issn do |index|
      index.as :stored_searchable
    end
    property :eissn, predicate: ::RDF::Vocab::BIBO.eissn do |index|
      index.as :stored_searchable
    end
    property :official_link, predicate: ::RDF::Vocab::SCHEMA.url  do |index|
      index.as :stored_searchable
    end
    property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
      index.as :stored_searchable, :facetable
    end
  end
end
end

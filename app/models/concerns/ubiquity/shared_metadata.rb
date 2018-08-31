module Ubiquity
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
      property :series_name, predicate: ::RDF::Vocab::BF2.subseriesOf do |index|
        index.as :stored_searchable, :facetable
      end
      property :edition, predicate: ::RDF::Vocab::BF2.edition, multiple: false do |index|
        index.as :stored_searchable
      end
      property :event_title, predicate: ::RDF::Vocab::BF2.term(:Event) do |index|
        index.as :stored_searchable, :facetable
      end
      property :event_date, predicate: ::RDF::Vocab::Bibframe.eventDate do |index|
        index.as :stored_searchable
      end
      property :book_title, predicate: ::RDF::Vocab::BIBO.term(:Proceedings), multiple: false do |index|
        index.as :stored_searchable, :facetable
      end
      property :journal_title, predicate: ::RDF::Vocab::BIBO.Journal, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end
      property :issue, predicate: ::RDF::Vocab::Bibframe.term(:Serial), multiple: false do |index|
        index.as :stored_searchable
      end
      property :article_num, predicate: ::RDF::Vocab::BIBO.number  do |index|
        index.as :stored_searchable
      end
    end
  end
end

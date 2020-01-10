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
      property :event_location, predicate: ::RDF::Vocab::Bibframe.eventPlace do |index|
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
      property :article_num, predicate: ::RDF::Vocab::BIBO.number, multiple: false do |index|
        index.as :stored_searchable
      end
      property :isbn, predicate: ::RDF::Vocab::BIBO.isbn, multiple: false do |index|
        index.as :stored_searchable
      end
      property :media, predicate: ::RDF::Vocab::MODS.physicalForm do |index|
        index.as :stored_searchable
      end
      property :related_exhibition, predicate: ::RDF::Vocab::SCHEMA.term(:ExhibitionEvent) do |index|
        index.as :stored_searchable
      end
      property :related_exhibition_date, predicate: ::RDF::Vocab::SCHEMA.term(:Date) do |index|
        index.as :stored_searchable
      end

      property :version, predicate: ::RDF::Vocab::SCHEMA.version do |index|
        index.as :stored_searchable
      end

      property :version_number, predicate: ::RDF::Vocab::SCHEMA.version do |index|
        index.as :stored_searchable
      end

      property :alternative_journal_title, predicate: ::RDF::Vocab::SCHEMA.alternativeHeadline, multiple: true do |index|
        index.as :stored_searchable
      end

      property :related_exhibition_venue, predicate: ::RDF::Vocab::SCHEMA.EventVenue, multiple: true do |index|
        index.as :stored_searchable
      end

      property :current_he_institution, predicate: ::RDF::Vocab::SCHEMA.EducationalOrganization, multiple: false do |index|
        index.as :stored_searchable
      end

      property :qualification_name, predicate: ::RDF::Vocab::SCHEMA.qualifications, multiple: false do |index|
        index.as :stored_searchable
      end

      property :qualification_level, predicate: ::RDF::Vocab::BF2.degree, multiple: false do |index|
        index.as :stored_searchable
      end

      property :duration, predicate: ::RDF::Vocab::BF2.duration, multiple: true do |index|
        index.as :stored_searchable
      end

      property :additional_links, predicate: ::RDF::Vocab::SCHEMA.significantLinks, multiple: false do |index|
        index.as :stored_searchable
      end

      property :degree, predicate: ::RDF::Vocab::SCHEMA.evidenceLevel, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :irb_number, predicate: ::RDF::Vocab::BIBO.identifier, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :irb_status, predicate: ::RDF::Vocab::BF2.Status, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :location, predicate: ::RDF::Vocab::BF2.physicalLocation , multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :outcome, predicate: ::RDF::Vocab::SCHEMA.resultComment, multiple: false do |index|
        index.as :stored_searchable
      end

      property :participant, predicate: ::RDF::Vocab::BF2.Person, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end

      property :reading_level, predicate: ::RDF::Vocab::SCHEMA.proficiencyLevel, multiple: false do |index|
        index.as :stored_searchable
      end

      property :challenged, predicate: ::RDF::Vocab::SCHEMA.quest, multiple: false do |index|
        index.as :stored_searchable
      end

      property :photo_caption, predicate: ::RDF::Vocab::SCHEMA.caption, multiple: false do |index|
        index.as :stored_searchable
      end

      property :photo_description, predicate: ::RDF::Vocab::SCHEMA.photo, multiple: false do |index|
        index.as :stored_searchable
      end

      property :buy_book, predicate: ::RDF::Vocab::SCHEMA.BuyAction, multiple: true do |index|
        index.as :stored_searchable
      end

      property :page_display_order_number, predicate: ::RDF::Vocab::SCHEMA.orderNumber, multiple: false do |index|
        index.as :stored_searchable
      end

    end
  end
end

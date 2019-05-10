module Ubiquity
  class CrossrefResponse
    attr_reader :error, :attributes
    def initialize(response_hash = nil)
      @error = error
      @attributes = response_hash['message']
    end

    def title
      attributes['title']
    end

    def abstract
      # For removing the Jat tags inside the abstract
      ActionView::Base.full_sanitizer.sanitize attributes['abstract']
    end

    def version
      attributes['message-version']
    end

    def date_published_year
      attributes['published-online']['date-parts'].first[0] if attributes['published-online'].present?
    end

    def date_published_month
      attributes['published-online']['date-parts'].first[1] if attributes['published-online'].present?
    end

    def date_published_day
      attributes['published-online']['date-parts'].first[2] if attributes['published-online'].present?
    end

    def issn
      attributes['ISSN'].first if attributes['ISSN'].present?
    end

    def eissn
      attributes['issn-type'].first['value'] if attributes['issn-type'].present?
    end

    def doi
      attributes['DOI']
    end

    def journal_title
      attributes['container-title'].first if attributes['container-title'].present?
    end

    def creator
      creator_group = attributes.dig('author') || attributes.dig('editor')
      if creator_group.present?
        if creator_group.first.keys && ['given', 'family', 'ORCID'].any?
          creator_with_seperated_names(creator_group)
        else
          creator_without_seperated_names(creator_group)
        end
      end
    end

    def creator_with_seperated_names(data)
      new_creator_group = []
      data.each_with_index do |hash, index|
        hash = {
          "creator_orcid" => hash['ORCID'].split('/').last,
          "creator_given_name" =>  hash["given"],
          "creator_family_name" => hash["family"],
          "creator_name_type" => 'Personal',
          "creator_position" => index
        }
        new_creator_group << hash
      end
      new_creator_group
    end

    def auto_populated_fields
      fields = []
      fields << 'title' if title.present?
      fields << 'creator' if creator.present?
      fields << "published year" if date_published_year.present?
      fields << "published month" if date_published_month.present?
      fields << "published day" if date_published_day.present?
      fields << 'DOI' if doi.present?
      fields << 'Journal Title' if journal_title.present?
      fields << 'ISSN' if issn.present?
      fields << 'eISSN' if eissn.present?
      fields << 'abstract' if abstract.present?
      # fields << 'version' if version.present?

      "The following fields were auto-populated - #{fields.to_sentence}"
    end

    def data
      if error.present?
        { 'error' => error }
      else
        {
          "title": title, "published_year": date_published_year,
          "published_month": date_published_month,
          "published_day": date_published_day,
          "issn": issn, "eissn": eissn, journal_title: journal_title,
          "abstract": abstract, "version": version,
          "creator_group": creator,
          "auto_populated": auto_populated_fields,
          "doi": doi
        }
      end
    end
  end
end

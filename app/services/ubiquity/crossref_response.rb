module Ubiquity
  class CrossrefResponse
    attr_accessor :error, :attributes
    def initialize(response_hash = nil, error = nil)
      @error = error
      @attributes = response_hash['message']
    end

    def title

    end

    def abstract
      attributes['abstract']
    end

    def version
      attributes['message-version']
    end

    def doi
      attributes['doi']
    end

    def journey_title
      attributes['container-title'].first
    end

    def data
      if error.present?
        {'error' => error}
      else
        {
          'related_identifier_group': related_identifier,
          "title": title, "published": date_published_year,
          "abstract": abstract, "version": version,
          "creator_group": creator, "license": license,
          "auto_populated": auto_populated_fields,
          "doi": doi
        }
      end
    end
  end
end

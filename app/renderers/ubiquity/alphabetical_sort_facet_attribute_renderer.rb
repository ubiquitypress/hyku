class AlphabeticalSortFacetAttributeRenderer < AlphabeticalSortAttributeRenderer

  def render
    super
  end

  private

  # copied from https://github.com/samvera/hyrax/blob/5a9d1be16ee1a9150646384471992b03aab527a5/app/renderers/hyrax/renderers/faceted_attribute_renderer.rb
    def li_value(value)
      link_to(ERB::Util.h(value), search_path(value))
    end

    def search_path(value)
      Rails.application.routes.url_helpers.search_catalog_path(:"f[#{search_field}][]" => value, locale: I18n.locale)
    end

    def search_field
      ERB::Util.h(Solrizer.solr_name(options.fetch(:search_field, field), :facetable, type: :string))
    end
end

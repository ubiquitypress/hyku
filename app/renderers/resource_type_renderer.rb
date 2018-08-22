# retrieve TERM instead of ID to display as documented here:
# http://samvera.github.io/customize-metadata-show-page.html#write-a-property-specific-custom-renderer

class ResourceTypeAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    %(<span itemprop="resource_type">#{::ResourceTypesService.label(value)}</span>)
  end
end

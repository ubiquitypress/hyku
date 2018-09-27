module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers

  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end

  # called in views/hyrax/base/_attribute_rows to avoid displaying empty content of multi-part fields on works show page
  def field_has_value?(field)
    field.delete("[{}]")
    field.present?
  end

  # override from blacklight/app/helpers/blacklight/facets_helper_behavior.rb
  def render_facet_partials fields = facet_field_names, options = {}
    safe_join(facets_from_request(fields).map do |display_facet|
      if display_facet.name == "resource_type_sim"
        display_facet.items.each do |i|
          i[:value] = human_readable_resource_type(i[:value])
        end
      end
      render_facet_limit(display_facet, options)
    end.compact, "\n")
  end
end

module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers

  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end

  # override from blacklight/app/helpers/blacklight/facets_helper_behavior.rb
  # to customise the resource_type search behaviour
  def facet_display_value field, item
    facet_config = facet_configuration_for_field(field)

    value = if field == "resource_type_sim"
              item.is_a?(Hash) ? human_readable_resource_type(item[:value]) : human_readable_resource_type(item)
            elsif item.respond_to? :label
              item.label
            else
              facet_value_for_facet_item(item)
            end

    if facet_config.helper_method
      send facet_config.helper_method, value
    elsif facet_config.query && facet_config.query[value]
      facet_config.query[value][:label]
    elsif facet_config.date
      localization_options = facet_config.date == true ? {} : facet_config.date

      l(value.to_datetime, localization_options)
    else
      value
    end
  end
end

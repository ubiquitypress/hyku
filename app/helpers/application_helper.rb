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
end

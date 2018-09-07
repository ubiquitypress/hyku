module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers

  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end
end

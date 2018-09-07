module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers
  
  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end

  ## method below was worked out reading http://jessiekeck.com/customizing-blacklight/metadata_fields/
  def display_alt_id_fields_in_search(options={})
    field = JSON.parse(options[:value][0]).map do |alt_id|
      alt_id["alternate_identifier"] << ", " << alt_id["alternate_identifier_type"]
    end
    field.join
  end

end

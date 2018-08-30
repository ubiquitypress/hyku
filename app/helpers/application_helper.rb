module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper

  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end

end

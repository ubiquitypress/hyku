module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers
  include Ubiquity::DateChangeHelper
  include Ubiquity::GoogleTagManagerHelper
  include Ubiquity::FileDisplayHelpers
  include Ubiquity::SharedSearchHelper

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

  def fetch_note_conversations(model, work_id)
    conversation_subject = model + '_' + work_id
    notes = Mailboxer::Conversation.where(subject: conversation_subject)
    sorted_notes = notes.sort_by(&:created_at)
    sorted_notes.map(&:id)
  end

  # in shared_behaviors_controller, `notes_on_work` method saves a href in the text to be used in the notifications page
  # so the text looks like: "(<a href=\"/concern/book_contributions/4f5417bc-0643-4f79-9ead-09caf7c82a77\">id</a>) lorem ipsum dolor etc"
  def split_note_from_work(note_text)
    note_text.split('</a>)').last
  end

  def ubiquity_url_parser(original_url)
    full_url = URI.parse(original_url)
    full_url.host.split('.').first
  end

  # For image thumbnails, override the default size for a better resolution on homepage
  def render_related_img(solr_doc)
    img_path = solr_doc['thumbnail_path_ss'].presence || ['/assets/collection-a38b932554788aa578debf2319e8c4ba8a7db06b3ba57ecda1391a548a4b6e0a.png']
    img_path = img_path.split('!150,300').join(',600') if img_path.include?('!150,300')
    image_tag img_path
  end

  def parse_environment_variable_json(original_url)
    cname = ubiquity_url_parser(original_url)
    JSON.parse(ENV[cname.upcase]) if cname.present?
  end

end

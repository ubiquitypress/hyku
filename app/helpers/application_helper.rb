module ApplicationHelper
  include ::HyraxHelper
  include GroupNavigationHelper
  include MultipleMetadataFieldsHelper
  include Ubiquity::SolrSearchDisplayHelpers
  include Ubiquity::DateChangeHelper
  include Ubiquity::GoogleTagManagerHelper
  include Ubiquity::FileDisplayHelpers
  include Ubiquity::SharedSearchHelper
  include Ubiquity::WorkShowActionsHelper
  include Ubiquity::SettingsHelper

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
    if full_url.host.present? && full_url.host.class == String
      full_url.host.split('.').first
    end
  end

  # For image thumbnails, override the default size for a better resolution on homepage
  def render_related_img(doc)
    solr_doc = FileSet.find(doc.id)
    return nil if solr_doc.original_file.versions.all.blank?
    img_path = CGI.escape(ActiveFedora::File.uri_to_id(solr_doc.original_file.versions.all.last.uri))
    # img_path = solr_doc['thumbnail_path_ss'].presence || ['/assets/collection-a38b932554788aa578debf2319e8c4ba8a7db06b3ba57ecda1391a548a4b6e0a.png']
    image_tag "#{img_path}/full/150,120/0/default.jpg"
  end

  def render_thumbnail_on_list(file_set, size = '100,80')
    solr_doc = FileSet.find(file_set.id)
    return nil if solr_doc.original_file.versions.all.blank?
    img_path = CGI.escape(ActiveFedora::File.uri_to_id(solr_doc.original_file.versions.all.last.uri))
    image_tag "#{img_path}/full/#{size}/0/default.jpg"
  end

  def verify_valid_json?(data)
    !!JSON.parse(data)  if data.class == String
    rescue JSON::ParserError
      false
  end

  def get_tenant_settings_hash(original_url)
    cname = ubiquity_url_parser(original_url)
    parse_tenant_settings_json(cname)
  end

  def parse_tenant_settings_json(cname)
    json_data = ENV['TENANTS_SETTINGS']
    if cname.present? && verify_valid_json?(json_data)
      settings_hash = JSON.parse(json_data)
      #returns tenant settings hash or empty hash if that tenant has no seetings in TENANT_SETTINGS
      settings_hash.fetch(cname, {})
    else
      #return empty hash  when no TENANT_SETTINGS since we expect a hash in the views
      #else it thows NoMethodError: undefined method `[]' for nil:NilClass

      {}
    end
  end

  def all_tenant_settings_keys
    json_data = ENV['TENANTS_SETTINGS']
    if verify_valid_json?(json_data)
      JSON.parse(json_data).keys
    end
  end

  def feature_list
    feature_json = ENV['FEATURE_ENABLED']
    if feature_json.present? && verify_valid_json?(feature_json)
     JSON.parse(feature_json)
   else
     #return empty hash since we expect a hash in the views
     #else it thows NoMethodError: undefined method `[]' for nil:NilClass

     {}
   end
  end

  def check_is_parent_shared_search_page
    @record =  Account.where(cname: request.host, data: {'is_parent': 'true'}).first
  end

  def get_tenant_settings
    json_data = ENV['TENANTS_SETTINGS']
      if json_data.present? && json_data.class == String
      JSON.parse(json_data)
    end
  end

end

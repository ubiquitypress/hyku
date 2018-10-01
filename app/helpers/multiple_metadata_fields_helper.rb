module MultipleMetadataFieldsHelper

  def render_isni_or_orcid_url(id, type)
    new_id = id.delete(' ')
    uri = URI.parse(new_id)

    if %(http https).include? uri.scheme
      uri
    end
  rescue URI::BadURIError, StandardError
      create_isni_and_orcid_url(id, type)
  end

  def create_isni_and_orcid_url(id, type)
    new_id = id.delete(' ')
    uri = URI.parse(new_id)
    if type == 'orcid'
      host = URI('https://orcid.org/')
      host.path = "/#{new_id}"
      host.to_s
    else
      host = URI('http://www.isni.org')
      host.path = "/isni/#{new_id}"
      host.to_s
    end
  end

  #Here we are checking in the works and search result page if the hash_keys for json fields
  # include values for either isni or orcid before displaying parenthesis
  def display_paren?(hash_keys, valid_keys)
    (hash_keys & valid_keys).any?
  end

  #Here we are checking in the works and search result page if the hash_keys for json fields
  # include a subset that is an array that includes either isni or orcid alongside contributor type before displaying a comma
  def display_comma?(hash_keys, valid_keys)
    all_keys_set = hash_keys.to_set
    if valid_keys == ["contributor_type", "contributor_orcid", "contributor_isni"]
      keys_with_orcid_id = valid_keys.take(2)
      keys_with_isni_id = [valid_keys.first, valid_keys.last]
      array_with_orcid_id_set = keys_with_orcid_id.to_set
      array_with_isni_id_set = keys_with_isni_id.to_set
      array_with_orcid_id_set.subset? all_keys_set or array_with_isni_id_set.subset? all_keys_set
    else
      needed_keys_set = valid_keys.to_set
      needed_keys_set.subset? all_keys_set
    end
  end

  def get_model(model_class, model_id, field, multipart_sort_field_name = nil)
    model ||= fetch_model(model_class, model_id)
    record ||= model.send(field.to_sym)
    get_json_data = record.first if !record.empty?
    value =   get_json_data || model

    # if passed in field = contributor and it is nil, return getch model using creator
    # return empty string if passed in field has value in database ie (value == nil)
    return ""  if (value == nil)

    if valid_json?(value)
      # when an creator is an array witha json string
      # same as  JSON.parse(model.creator.first)
      array_of_hash ||= JSON.parse(model.send(field.to_sym).first)
      return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name
      array_of_hash
    else
      # returned when field is not a json. Return array to avoiding returning ActiveTriples::Relation
      record || [value.attributes]
    end
  end

  private

  # return false if json == String
  def valid_json?(data)
    # return if json == nil
    !!JSON.parse(data)  if data.class == String
    rescue JSON::ParserError
      false
  end

  def fetch_model(model_class, model_id)
    # from edit page the model class is a constant but from show page it is a string
    if model_class.class == String
      (model_class.constantize).find(model_id)
    else
      model_class.find(model_id)
    end
  end

  def sort_hash(array_of_hash, key)
    return array_of_hash if array_of_hash.class != Array
    if key.present?
      array_of_hash.sort_by!{ |hash| hash[key].to_i}
      array_of_hash.map {|hash| hash.reject { |k,v| v.nil? || v.to_s.empty? ||v == "NaN" }}
    end
  end
end

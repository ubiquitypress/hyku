module MultipleMetadataFieldsHelper

  #receives a file_set when called from views/hyrax/base/_representative_media.html.erb
  #receives a Hyku::FileSetPresenter when called from views/shared/ubiquity/works/_member.html.erb
  #used when work type was passed in
  #  data = data.thumbnail if data.class != Hyku::FileSetPresenter
  #
  def zipped_types
    %w[zip zipx bz2 gz dmg rar sit sitx tar tar.gz tgz tar.Z tar.bz2 tbz2 tar.lzma tlz tar.xz txz].freeze
  end
  def check_file_is_restricted?(data)
    if (current_user.present? && ((current_user.roles_name.include? "admin") || data.depositor == current_user.email || (can? :manage, data)) && ((data.lease_expiration_date.present?) || (data.embargo_release_date.present?) ) )
      true
    else
      false
    end
  end

  #receives a id reprsents a thumbnail_id and is used to fetch and return a file_set
  def get_media_model(id, host=nil)
    if id.class == String
      ::AccountElevator.switch!("#{host}") if host.present?
      file_set =  ActiveFedora::Base.find(id)
    end
  end

  def check_for_zip(name)
    File.extname(name)
  end

  def file_set_solr_doc(file_set)
     SolrDocument.new(file_set.to_solr)
  end

  #called in app/views/hyrax/collection/_sort_and_per_page.html
  #sort_fields is 2 dimensional array
  def ubiquity_sort_field(sort_array)
    sort_array - [["relevance", "score desc, system_create_dtsi desc"], ["date modified ▼", "system_modified_dtsi desc"], ["date modified ▲", "system_modified_dtsi asc"]]
  end

  #takes in the creator value passed in from a solr document
  #It receives an array containing a single json string eg ['[{creator_family_name: mike}, {creator_given_name: hu}]']
  #We parse that json into an array of hashes as in [{creator_family_name: mike}, {creator_given_name: hu}]
  #called from app/views/shared/ubiquity/collections/_show_document_list_row
  def display_json_values(json_record)
    #parse the json into an array
    Ubiquity::ParseJson.new(json_record).data
  end

  def render_isni_or_orcid_url(id, type)
    new_id = id.delete(' ')
    uri = URI.parse(new_id)
    if (uri.scheme.present? &&  uri.host.present?)
      domain = uri
      domain.to_s
    elsif (uri.scheme.present? == false && uri.path.present?)
      split_path(uri, type)
    elsif (uri.scheme.present? == false && uri.host.present? == false)
      create_isni_and_orcid_url(new_id, type)
    end
  end

  #The uri looks like  `#<URI::Generic orcid.org/0000-0002-1825-0097>` hence the need to split_path;
  # `split_domain_from_path` returns `["orcid.org", "0000-0002-1825-0097"]`
  # get_type is subsctracting a sub array from the main array eg (["orcid", "org"] - ["org"]) and returns ["orcid"]
  def split_path(uri, type)
    split_domain_from_path = uri.path.split('/')
    if split_domain_from_path.length == 1
      id = split_domain_from_path.join('')
      create_isni_and_orcid_url(id, type)
    else
      get_host = split_domain_from_path.shift
      split_host = get_host.split('.')
      get_type = (split_host - ['org']).join('')
      get_id = split_domain_from_path.join('')
      create_isni_and_orcid_url(get_id, get_type)
    end
  end

  def create_isni_and_orcid_url(id, type)
    if type == 'orcid'
      host = URI('https://orcid.org/')
      host.path = "/#{id}"
      host.to_s
    elsif type == "isni"
      host = URI('http://www.isni.org')
      host.path = "/isni/#{id}"
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
    if (valid_keys == ["contributor_type", "contributor_orcid", "contributor_isni"])
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

  def add_image_space?(hash_keys)
    get_name = get_field_name(hash_keys)
    desired_fields = ["#{get_name}_orcid", "#{get_name}_isni"]
    desired_fields.to_set.subset? hash_keys.to_set
  end

  def get_field_name(hash_keys)
    if hash_keys.present?
      first_key = hash_keys.first
      first_key.split('_').first
    end
  end

  def get_model(model_class, model_id, field, multipart_sort_field_name = nil)
    model ||= fetch_model(model_class, model_id)
    #get the record store in that field
    record ||= model.send(field.to_sym)
    get_json_data = record.first if (!record.empty?)

    #If the value of the first is record is nil return the model
    @value =   get_json_data || model

    if valid_json?(@value)
      array_of_hash ||= JSON.parse(record.first)
      return  [model.attributes] if (array_of_hash.first.class == String  || array_of_hash.first.nil? )

      #return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name
      return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name

      array_of_hash
    end
  end

  private

  # return false if json == String
  def valid_json?(data)
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
    #return array_of_hash if array_of_hash.class != Array

    if (key.present? && array_of_hash.first.class == Hash)
      #allows the sort to function even if the value of a hash is nil
      array_of_hash.sort_by{ |hash| hash[key].to_i}
    end
  end

end

module JournalArticlesHelper

  def get_model(model_class, model_id, field, multipart_sort_field_name)
    model = fetch_model(model_class, model_id)
    value = model.creator.first
    if valid_json?(value)

      #when an creator is an array witha json string
      #same as  JSON.parse(model.creator.first)
      array_of_hash = JSON.parse(model.send(field.to_sym).first)
      sort_hash(array_of_hash, multipart_sort_field_name)
    else
      #since it is the returned value is not a json leave it as array otherwise calling first returns string value
      model.send(field.to_sym)
    end
  end

  private

  def valid_json?(json)
    !!JSON.parse(json)
    rescue JSON::ParserError => _e
      false
  end

  def fetch_model(model_class, model_id)
    #from edit page the model class is a constant but from show page it is a string
    if model_class.class == String
      (model_class.constantize).find(model_id)
    else
      model_class.find(model_id)
    end
  end

  def sort_hash(array_of_hash, key)
    return if array_of_hash.class != Array
    array_of_hash.sort_by!{|hash| hash[key]}
  end

end

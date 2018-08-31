module JournalArticlesHelper

  def get_model(model_class, model_id, field, multipart_sort_field_name)
    model = fetch_model(model_class, model_id)
    value = model.send(field.to_sym).first

    #if passed in field = contributor and it is nil, return getch model using creator
    #return empty string if passed in field has value in database ie (value == nil)
    return ""  if (value == nil)

    if valid_json?(value)
      #when an creator is an array witha json string
      #same as  JSON.parse(model.creator.first)
      array_of_hash = JSON.parse(model.send(field.to_sym).first)
      sort_hash(array_of_hash, multipart_sort_field_name)
    else
      #returned when field is not a json. Return array to avoiding returning ActiveTriples::Relation
      model.send(field.to_sym).to_a
    end
  end

  private

  def valid_json?(json)
    #return if json == nil
    !!JSON.parse(json)
    rescue JSON::ParserError
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
    return array_of_hash if array_of_hash.class != Array
    array_of_hash.sort_by!{|hash| hash[key] if hash[key].present? }
  end

end

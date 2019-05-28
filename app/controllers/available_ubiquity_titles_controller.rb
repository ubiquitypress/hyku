class AvailableUbiquityTitlesController < ApplicationController
  def check
    should_find_title = false
    title_present_ary = []
    title = params["title"]
    alternative_title = params["alternative_title"]
    both_title = [params["title"]] + params["alternative_title"].to_a
    returned_titles = get_records(title, alternative_title)
      if returned_titles.present?
        title_present_ary.push(*returned_titles)
        should_find_title = true
      end
    if should_find_title
      render json: { "data": 'true', "message": title_unavailable_message_based_on_count(title_present_ary), "title_list": title_present_ary}
    else
      render json: { "data": 'false', "message": title_available_message_based_on_count(both_title) }
    end
  end

  def call_datasite
    url = params["url"]
    datacite = Ubiquity::DataciteClient.new(url).fetch_record
    render json: { 'data': datacite.data }
  end
end


private

 def find_title(title)
   data = params["model_class"].constantize.where(title: title).first
 end

 def find_alternative_title(alternative_title)
   data = params["model_class"].constantize.where(alternative_title: alternative_title) #.first
 end

  def get_records(title, alternative_title)
    title_object = find_title(title).try(:title)
    alternative_titles_array = find_alternative_title(alternative_title)
    all_existing_titles = []
    alternative_titles_array.each {|object| all_existing_titles.push(*object.alternative_title)}
    #calling to_a on Active Triple relation
    if all_existing_titles && title_object
      records = all_existing_titles.to_a + title_object.to_a
      elsif all_existing_titles
        all_existing_titles.to_a
      elsif  title_object
        title_object.title.to_a
    end
  end

  def add_all_titles(alternative_titles_array, title_object)
    if all_existing_titles && title_object
      records = all_existing_titles.to_a + title_object.to_a
    elsif all_existing_titles
      all_existing_titles.to_a
    elsif  title_object
       title_object.title.to_a
    end
  end

  def title_unavailable_message_based_on_count(record_ary)
    if record_ary.count > 1
      'The Following Titles are being used: '
    else
      'This Title is being used: '
    end
  end

  def title_available_message_based_on_count(record_ary)
    record_ary.reject!(&:blank?)
    if record_ary.count > 1
      'The Titles are available'
    else
      'This Title is available'
    end
  end

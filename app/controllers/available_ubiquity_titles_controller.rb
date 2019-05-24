class AvailableUbiquityTitlesController < ApplicationController
  def check
    find_title = false
    title_present_ary = []
    title_ary = params["title"]
    title_ary.each do |title|
      data = params["model_class"].constantize.where(title: title).first
      if data.present?
        title_present_ary << " #{title}"
        find_title = true
      end
    end
    if find_title
      render json: { "data": 'true', "message": title_unavailable_message_based_on_count(title_present_ary), "title_list": title_present_ary}
    else
      render json: { "data": 'false', "message": title_available_message_based_on_count(title_ary) }
    end
  end

  def call_datasite
    url = params["url"]
    datacite = Ubiquity::DataciteClient.new(url).fetch_record
    render json: { 'data': datacite.data }
  end
end


private

  def title_unavailable_message_based_on_count(title_ary)
    if title_ary.count > 1
      'The Following Titles are being used: '
    else
      'This Title is being used: '
    end
  end

  def title_available_message_based_on_count(title_ary)
    title_ary.reject!(&:blank?)
    if title_ary.count > 1
      'The Titles are available'
    else
      'This Title is available'
    end
  end

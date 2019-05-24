class AvailableUbiquityTitlesController < ApplicationController
  def check
    find_title = false
    title_present_ary = []
    title_ary = params["title"]
    title_ary.each do |title|
      data = params["model_class"].constantize.where(title: title).first
      if data.present?
        title_present_ary << title
        find_title = true
      end
    end
    if find_title
      render json: { "data": 'true', "message": "Following Title/Titles are taken: ", "title_list": title_present_ary }
    else
      render json: { "data": 'false', "message": "Title is available" }
    end
  end

  def call_datasite
    url = params["url"]
    datacite = Ubiquity::DataciteClient.new(url).fetch_record
    render json: { 'data': datacite.data }
  end
end

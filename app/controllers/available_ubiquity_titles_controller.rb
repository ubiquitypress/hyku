class AvailableUbiquityTitlesController < ApplicationController
  def check
    model = params["model_class"]
    title = params["title"]
    data = model.constantize.where(title: title).first

     if data.present?
       render json: {"data": 'true', "message": "Title is taken"}
     else
       render json: {"data": 'false', "message": "Title is available"}
     end
  end

  def call_datasite
    url = params["url"]
    datacite = Ubiquity::DataciteClient.new(url).fetch_record
    render json: {'data': datacite.data}
  end
  
  def csv_export
    #data = Ubiquity::CsvDownloader.export_database
    #data = Ubiquity::CsvDownloader.export_models
    data = Ubiquity::CsvDownloader.ha
    respond_to do |format|
      #, content_type: 'text/plain'
      format.csv {render plain: data, content_type: 'text/plain'}
    end
  end

end

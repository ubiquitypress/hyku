class AvailableUbiquityTitlesController < ApplicationController
  def check
     data = model.constantize.where(title: title ).first
     
     if data.present?
       render json: {"data": 'true', "message": "Title is taken"}
     else
       render json: {"data": 'false', "message": "Title is available"}
     end
  end
end

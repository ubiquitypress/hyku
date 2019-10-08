class API::V1::ErrorsController < ActionController::Base 
  def index
    render json: [errors: params[:errors] ]
  end

end

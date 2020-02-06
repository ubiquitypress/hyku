require 'jwt'
module Ubiquity
  module ApiErrorHandlers
    extend ActiveSupport::Concern

    included do
      rescue_from StandardError do |exception|
        other_errors(exception)
      end

      rescue_from RSolr::Error::Http, ActiveFedora::ObjectNotFoundError do |exception|
        render_error(exception)
      end

      rescue_from Ubiquity::ApiError do |exception|
         render_custom_error(exception)
      end

      rescue_from ::JWT::ExpiredSignature, with: :expired_session
      rescue_from ::JWT::DecodeError, ::JWT::VerificationError, with: :invalid_token

    end

    private

    def render_error(exception)
      if exception.class == ActiveFedora::ObjectNotFoundError
        message =  exception.to_s.gsub('ActiveFedora::Base', 'record')
        error_object = Ubiquity::ApiError::NotFound.new(status: 404, code: 'not_found', message: message)
      end
      if exception.class == RSolr::Error::Http
        message = "Please check the request path #{request.path} & ensure you add per_page if you" \
        "send back just #{request.fullpath}. That is do not send only ?page=number given"

        error_object = Ubiquity::ApiError::NotFound.new(status: 400, code: 'Bad Request', message: message)
      end
      render json: error_object.error_hash
    end

    def render_custom_error(message)
      render json: message.error_hash
    end


    def other_errors(exception)
      message = "This request #{request.original_fullpath} threw an error #{exception}, please check it and try again"
      error_object = Ubiquity::ApiError::NotFound.new(status: 500, code: 'Server Error', message: message)
      render json: error_object.error_hash
    end

    def expired_session
      message = 'Expired session, please login again'
      error_object = Ubiquity::ApiError::NotFound.new(status: 401, code: 'Unathorized', message: message)
      render json: error_object.error_hash
    end

    def invalid_token
      message = 'Invalid token'
      error_object = Ubiquity::ApiError::NotFound.new(status: 401, code: 'Unathorized', message: message)
      render json: error_object.error_hash
    end

  end
end

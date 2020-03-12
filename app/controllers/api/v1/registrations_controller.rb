class API::V1::RegistrationsController <  API::V1::ApiBaseController
  include Ubiquity::ApiUserUtils

  def create
    AccountElevator.switch!(current_account.cname)
    user = User.new(email: api_user_params['email'], password: api_user_params['password'],
              password_confirmation: api_user_params['password_confirmation'])
              
    if user.valid? && user.save
      token = payload(user)
      set_response_cookie(token)
      participants = adminset_permissions(user)
      user_type = user_roles(user)
      render json: user.slice(:email).merge({participants: participants, type: user_type })
    else
      message = user.errors.messages
      error_object = Ubiquity::ApiError::NotFound.new(status: 401, code: 'Invalid credentials', message: message)
      render json: error_object.error_hash
    end
  end

end

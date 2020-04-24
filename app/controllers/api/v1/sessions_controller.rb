class API::V1::SessionsController < API::V1::ApiBaseController
  include Ubiquity::ApiUserUtils

  def create
    user = User.find_for_database_authentication(email: api_user_params[:email])
    if user && user.valid_password?(api_user_params[:password]) && user.confirmed?
      token = payload(user)
      set_response_cookie(token)
      participants = adminset_permissions(user)
      user_type = user_roles(user)
      render json: user.slice(:email).merge({participants: participants, type: user_type })
    else
      user_error
    end
  end

  def destroy
    domain = ('.' + request.host)
    response.set_cookie(
        :jwt,
          {
            value: '', expires: 10000.hours.ago, path: '/', same_site: :none,
            domain: domain, secure: true, httponly: true
        }
    )

    render json: {message: "Successfully logged out"}, status: 200
  end

  def refresh
    if current_user.present?
      token = payload(current_user)
      set_response_cookie(token)
      participants = adminset_permissions(user)
      user_type = user_roles(user)
      render json: current_user.slice(:email).merge({participants: participants, type: user_type })
    else
      user_error
    end
  end

  private

  def user_error
    message = 'Invalid email or password.'
    error_object = Ubiquity::ApiError::NotFound.new(status: 401, code: 'Invalid credentials', message: message)
    render json: error_object.error_hash
  end

end

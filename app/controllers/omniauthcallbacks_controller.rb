class OmniauthcallbacksController < Devise::OmniauthCallbacksController
  # handle omniauth logins from shibboleth
  def shibboleth
    # auth_headers = %w(HTTP_AFFILIATION HTTP_AUTH_TYPE HTTP_COOKIE HTTP_HOST
    #   HTTP_PERSISTENT_ID HTTP_EPPN HTTP_REMOTE_USER HTTP_SHIB_APPLICATION_ID
    #   HTTP_SHIB_AUTHENTICATION_INSTANT HTTP_SHIB_AUTHENTICATION_METHOD
    #   HTTP_SHIB_AUTHNCONTEXT_CLASS HTTP_SHIB_HANDLER HTTP_SHIB_IDENTITY_PROVIDER
    #   HTTP_SHIB_SESSION_ID HTTP_SHIB_SESSION_INDEX HTTP_UNSCOPED_AFFILIATION)
    #
    auth_headers = {
      :uid => 'HTTP_EPPN',
      :shib_session_id => 'HTTP_SHIB_SESSION_ID',
      :shib_application_id => 'HTTP_SHIB_APPLICATION_ID',
      :provider => 'HTTP_SHIB_IDENTITY_PROVIDER',
      :name => 'HTTP_EPPN'
    }
    auth = {}
    auth_headers.each do |k,v|
      auth[k] = request.headers[v]
    end
    # if auth.fetch('unscoped_affiliation', nil)
    #   auth['affiliation'] = auth['unscoped_affiliation'].split(';').map(&:strip)
    # end
    auth.delete_if { |k, v| v.blank? }
    @user = User.from_omniauth(auth)
    # capture data about the user from shib
    # session['shib_user_data'] = auth
    # set_flash_message :notice, :success, kind: "Shibboleth"
    sign_in_and_redirect @user
  end

  # def shibboleth
  #   @user = User.from_omniauth(request.headers)
  #   ## capture data about the user from shib
  #   ## session['shib_user_data'] = request.env["omniauth.auth"]
  #   sign_in_and_redirect @user
  # end

  ## when shib login fails
  def failure
    ## redirect them to the devise local login page
    # redirect_to new_local_user_session_path, :notice => "Shibboleth isn't available - local login only"
    redirect_to root_path, :notice => "Shibboleth isn't available - local login only"
  end

end

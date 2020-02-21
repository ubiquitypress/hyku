module ApiTestHelpers
  def post_request(user, expire)
    #"/api/v1/tenant/#{account.id}/users/login"
    post api_v1_user_login_url(tenant_id: account.id),  params: {
    email: user.email,
    password: user.password,
    expire: expire
    }
  end
end

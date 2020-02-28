require 'rails_helper'
require 'spec_helper'

RSpec.describe "API::V1::ReviewsController", type: :request do
  include ApiTestHelpers
  WebMock.disable!
  let!(:account) { create(:account) }
  let(:user_mgr) { create(:user, email: 'user_mgr@example.com') }
  let(:user_dep) { create(:user, email: 'user_dep@example.com') }

  after(:each) do
    user_mgr.destroy
    user_dep.destroy
    account.destroy
    @admin_set.destroy
    @work.destroy
    @permission_template.destroy
    @permission_template_access_dep.destroy
    @permission_template_access_mgr.destroy
  end

  describe "Manage work under review" do

    it "should be to add comment and change state" do

     @admin_set = instance_double(AdminSet, title: ['One step mediated deposit'])
     @permission_template = instance_double(Hyrax::PermissionTemplate, admin_set_id: @admin_set.id )
     @permission_template_access_dep = instance_double(Hyrax::PermissionTemplateAccess,
             permission_template_id: @permission_template.id, agent_type: "user", agent_id: user_dep.email,
             access: "deposit"
            )
     @permission_template_access_mgr = instance_double(Hyrax::PermissionTemplateAccess,
                    permission_template_id: @permission_template.id, agent_type: "user", agent_id: user_mgr.email,
                    access: "manage"
                   )

     @work = create(:work, user: user_dep, admin_set_id: admin_set.id)

      #sign_in as a user with depositor
      post api_v1_user_login_url(tenant_id: account.id), params: {
        email: user_dep.email,
        password: user_dep.password,
        expire: expire
      }

      parse_response = JSON.parse(response.body)
      returned_cookie = response[ "Set-Cookie"]
      headers =  {"Cookie" => "#{returned_cookie}", "ACCEPT" => "application/json"}

      puts "bam-work #{work.inspect}"
      #log out as a user with depositor permission
      get "/api/v1/tenant/#{account.id}/users/log_out", :headers => headers

      #resign in as an a user with manager persmission
      post api_v1_user_login_url(tenant_id: account.id), params: {
        email: user_mgr.email,
        password: user_mgr.password,
        expire: expire
      }

      new_returned_cookie = response[ "Set-Cookie"]
      new_headers =  {"Cookie" => "#{new_returned_cookie}", "ACCEPT" => "application/json"}

      post "/api/v1/tenant/#{account.id}/work/#{work.id}/reviews", params: {
        name: "comment_only",
        comment: "can manage workflow from api",

      }, headers: new_headers

      expect(response).to be_truthy
    end
  end
end

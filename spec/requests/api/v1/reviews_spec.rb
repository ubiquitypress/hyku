require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::ReviewsController, type: :request do
  before do
    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  let!(:depositing_user) { create(:user, :confirmed) }
  let!(:approving_user) { create(:user, :confirmed) }
  let!(:account) { create(:account) }
  let!(:admin_set) { create(:admin_set) }
  let!(:permission_template) { create(:permission_template, admin_set_id: admin_set.id) }
  let!(:permission_template_access) do
    create(:permission_template_access,
           :manage,
           permission_template: admin_set.permission_template,
           agent_type: 'user',
           agent_id: approving_user.user_key)
  end
  let!(:workflow) { create(:workflow, active: true, permission_template: permission_template) }
  let!(:work) { create(:work, user: depositing_user, admin_set_id: admin_set.id) }

  before do
    Hyrax::Workflow::WorkflowImporter.load_workflow_for(permission_template: permission_template)
    Sipity::Workflow.activate!(permission_template: permission_template, workflow_id: permission_template.available_workflows.find_by(name: 'one_step_mediated_deposit').id)
    Hyrax::Workflow::PermissionGenerator.call(roles: 'approving', workflow: workflow, agents: approving_user)
    # Need to instantiate the Sipity::Entity for the given work. This is necessary as I'm not creating the work via the UI.
    Hyrax::Workflow::WorkflowFactory.create(work, {}, depositing_user)
  end

  describe "/reviews" do
    context 'with proper privileges' do
      before do
        post api_v1_user_login_url(tenant_id: account.id), params: {
          email: approving_user.email,
          password: approving_user.password,
          expire: 2
        }
        @headers =  { "Cookie" => response['Set-Cookie'], "ACCEPT" => "application/json" }
      end

      it "adds comment" do
        expect do
          post "/api/v1/tenant/#{account.id}/work/#{work.id}/reviews", params: {
            name: "comment_only",
            comment: "can manage workflow from api",
          }, headers: @headers
        end.to change { PowerConverter.convert(work, to: :sipity_entity).reload.comments.count }.by(1)

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['data'][0]['comment']).to be_present
        expect(json_response['data'][0]['updated_at']).to be_present
        expect(json_response['workflow_status']).to eq 'pending_review'
      end

      it 'changes state' do
        expect do
          post "/api/v1/tenant/#{account.id}/work/#{work.id}/reviews", params: {
            name: "approve",
            comment: "can manage workflow from api",
          }, headers: @headers
        end.to change { PowerConverter.convert(work, to: :sipity_entity).reload.workflow_state_name }.from("pending_review").to("deposited")

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['data'][0]['comment']).to be_present
        expect(json_response['data'][0]['updated_at']).to be_present
        expect(json_response['workflow_status']).to eq 'deposited'
      end
    end

    context 'without proper privileges' do
      let(:end_user) { create(:user, :confirmed) }

      before do
        post api_v1_user_login_url(tenant_id: account.id), params: {
          email: end_user.email,
          password: end_user.password,
          expire: 2
        }
        @headers = { "Cookie" => response['Set-Cookie'], "ACCEPT" => "application/json" }
      end

      it 'returns an error json doc' do
        post "/api/v1/tenant/#{account.id}/work/#{work.id}/reviews", params: {
          name: "approve",
          comment: "can manage workflow from api",
        }, headers: @headers

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq(422)
        expect(json_response['code']).to eq "Unprocessable entity"
        expect(json_response['code']).to be_present
      end
    end
  end
end

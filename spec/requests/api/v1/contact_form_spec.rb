require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::ContactFormController, type: :request do
  let!(:account) { create(:account) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    @old_contact_email = Hyrax.config.contact_email
    Hyrax.config.contact_email = 'admin@example.com'
  end

  after do
    Hyrax.config.contact_email = @old_contact_email
  end

  describe "/contact_form" do
    it 'sends the contact form' do
      expect do
        post api_v1_tenant_contact_form_index_url(tenant_id: account.id), params: { category: 'general', name: 'Tove Jansson', email: 'moomin@example.com', subject: 'General inquiry', message: 'Message' }
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(response.status).to eq(200)
      expect(json_response['code']).to eq(201)
      expect(json_response['status']).to eq 'created'
    end

    context 'when spam' do
      it 'does not sent the contact form' do
        post api_v1_tenant_contact_form_index_url(tenant_id: account.id), params: { category: 'general', name: 'Tove Jansson', email: 'moomin@example.com', subject: 'General inquiry', message: 'Message', contact_method: 'email' }
        expect(response.status).to eq(200)
        expect(json_response['code']).to eq(422)
        expect(json_response['status']).to eq 'spam_not_sent'
      end
    end

    context 'when params missing' do
      it 'does not sent the contact form' do
        post api_v1_tenant_contact_form_index_url(tenant_id: account.id), params: { category: 'general', name: 'Tove Jansson', email: 'moomin@example.com', subject: 'General inquiry' }
        expect(response.status).to eq(200)
        expect(response.body).to eq "Your contact form is missing one of the following compulsory fields :name, :category, :email, :subject, :message"
      end
    end
  end
end
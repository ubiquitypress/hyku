class CreateFcrepoEndpointJob < ActiveJob::Base
  non_tenant_job

  def perform(account)
    name = account.tenant.parameterize

    account.create_fcrepo_endpoint(base_path: "/#{name}", url: fedora_url)
  end

  private

    def fedora_url
      uri = URI(Settings.fedora.url)
      uri.to_s
    end
end

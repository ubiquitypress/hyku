
AccountElevator.switch!(tenant.cname)
json.id  tenant.id
json.tenant  tenant.tenant
json.cname  tenant.cname
json.solr_endpoint  tenant.solr_endpoint_id
json.fcrepo_endpoint  tenant.fcrepo_endpoint_id
json.name  tenant.name
json.redis_endpoint  tenant.redis_endpoint_id
json.parent  tenant.parent_id
json.settings  tenant.settings
json.data  tenant.data
site = tenant.get_site
json.site  tenant.get_site.attributes.merge("banner_images": {"url": url_for("#{tenant.cname}#{site.banner_image}")})
json.content_block  tenant.get_content_block
json.google_tag_manager_id parse_tenant_settings_json(tenant.try(:name)).dig('GTM_ID')

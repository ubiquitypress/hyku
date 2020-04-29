# How to use
#change the cname as needed and copy the id of any work in the records of that cname
# work = Article.new(id: '2c0ec6fe-f47b-4e92-93d2-db86e1896b5c', account_cname: "bl.oar.uk", title: ['test'])
# f = Ubiquity::FetchTenantUrl.new(work)
# f.process_url
#
module Ubiquity
  class FetchTenantUrl

    def initialize(object)
      @account_cname = object.try(:account_cname)
      @id = object.try(:id)
      @work_type = object.try(:has_model).try(:first).to_s
      @is_collection = object.collection?
      @settings = Ubiquity::ParseTenantWorkSettings.new(@account_cname)
      @settings_hash = @settings.tenant_settings_hash
      @subdomain = @settings.get_tenant_subdomain
    end

    def process_url
      return nil if @account_cname.nil?
      work_type = @work_type.tableize

      if @settings && @settings_hash.present? && @settings_hash[@subdomain].present? && @settings_hash[@subdomain]['live'].present?
        @account_cname = @settings_hash[@subdomain]['live']
      end

      if @account_cname.split('.').include? 'localhost'
        @is_collection ? "http://#{@account_cname}:3000/#{work_type}/#{@id}" : "http://#{@account_cname}:3000/concern/#{work_type}/#{@id}"
      elsif @settings_hash.present? && @settings_hash[@subdomain].present? && @settings_hash[@subdomain]['live'].present?
        @is_collection ? "https://#{@account_cname}/collection/#{@id}" : "https://#{@account_cname}/work/#{@id}"
      else
        @is_collection ? "https://#{@account_cname}/#{work_type}/#{@id}" : "https://#{@account_cname}/concern/#{work_type}/#{@id}"
      end
    end
  end
end

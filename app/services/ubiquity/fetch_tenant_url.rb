module Ubiquity
  class FetchTenantUrl

    def initialize(object)
      @account_cname = object.try(:account_cname)
      @id = object.try(:id)
      @work_type = object.try(:has_model).try(:first).to_s
      @is_collection = object.collection?
      @settings = Ubiquity::ParseTenantWorkSettings.new(@account_cname).tenant_work_settings_hash
    end

    def process_url
      return nil if @account_cname.nil?
      work_type = @work_type.tableize
      @account_cname = @account_cname.gsub(@settings['sub_cname']['api'], @settings['sub_cname']['live']) if @account_cname == @settings['sub_cname']['api'] && @settings['sub_cname']['api'].present?

      if @account_cname.split('.').include? 'localhost'
        @is_collection ? "http://#{@account_cname}:3000/#{work_type}/#{@id}" : "http://#{@account_cname}:3000/concern/#{work_type}/#{@id}"
      else
        @is_collection ? "https://#{@account_cname}/collection/#{@id}" : "https://#{@account_cname}/work/#{@id}"
      end
      
    end
  end
end

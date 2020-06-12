#code reverting csv column headers for export
#https://github.com/ubiquitypress/hyku/pull/433
#every code in this gist came from the commit below which ensured csv export headers matched the imported csv headers
#https://github.com/ubiquitypress/hyku/pull/403
#https://trello.com/c/8QuJT627/411-v15924-make-improvements-to-export-a-csv-file-of-the-repository-metadata-revert-before-release-to-live
#
# Usage
# a = Ubiquity::Exporter::CsvData.new('university-demo.localhist').fetch_all_record
#
module Ubiquity

  class Exporter::CsvData
    attr_accessor :article, :book, :book_contribution, :conference_item,
                :dataset, :image, :report, :generic_work,
                :all_data, :all_records, :cname_or_original_url

    def initialize(cname_or_original_url)
      @all_records = []
      @all_data = []
      @cname_or_original_url = cname_or_original_url
    end

    def fetch_all_record
      switch_account_tenant
      puts "===== starting remapping all records ===="
      model_class_names = Ubiquity::SharedMethods.tenant_work_list(cname_or_original_url)
      model_class_names.each do |model_name|
        @all_records <<  model_name.to_csv
      end

      puts "====== finished remapping all records  ====="
      all_records.flatten!

      self
    end

    private

    def switch_account_tenant
      tenant_uuid = Apartment::Tenant.current
      if tenant_uuid.present?
        tenant = Account.where(tenant: tenant_uuid).first
        tenant_name = tenant.cname if tenant.present?
        AccountElevator.switch!("#{tenant_name}") if tenant_name.present?
      end
    end

  end
end

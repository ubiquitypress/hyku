#code reverting csv column headers for export
#https://github.com/ubiquitypress/hyku/pull/433
#every code in this gist came from the commit below which ensured csv export headers matched the imported csv headers
#https://github.com/ubiquitypress/hyku/pull/403
#https://trello.com/c/8QuJT627/411-v15924-make-improvements-to-export-a-csv-file-of-the-repository-metadata-revert-before-release-to-live

module Ubiquity

  class CsvData
    attr_accessor :article, :book, :book_contribution, :conference_item,
                :dataset, :image, :report, :generic_work,
                :all_data, :all_records

    def initialize
      @all_records = []
      @all_data = []
    end

    def fetch_all_record
      switch_account_tenant
      puts "===== starting remapping all records ===="

       Hyrax.config.curation_concerns.each do |model_name|
           @all_records <<  model_name.csv_data
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

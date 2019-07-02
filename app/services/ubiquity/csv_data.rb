module Ubiquity

  class CsvData
    attr_accessor :article, :book, :book_contribution, :conference_item,
                :dataset, :image, :report, :generic_work,
                :all_data, :all_records

    def initialize
      #switch_account_tenant
      @all_records = []
      @all_data = []
    end

    def fetch_all_record
      switch_account_tenant
      Article.find_each {|record| @all_records <<  Ubiquity::CsvDataRemap.new(record).new_data if record.present?}
      Book.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      BookContribution.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present? }
      ConferenceItem.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      Dataset.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      Image.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      Report.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      GenericWork.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      ExhibitionItem.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      ThesisOrDissertation.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}
      TimeBasedMedia.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).new_data  if record.present?}

      self
    end

    private

    def switch_account_tenant
      tenant_uuid = Apartment::Tenant.current
        puts "tenant-ibo #{tenant_uuid}"
      if tenant_uuid.present?
        tenant = Account.where(tenant: tenant_uuid).first
        puts "tenant-uyo #{tenant.cname}"

        tenant_name = tenant.cname if tenant.present?
        AccountElevator.switch!("#{tenant_name}") if tenant_name.present?
      end
    end

  end
end

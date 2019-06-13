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
      Article.find_each {|record| @all_records <<  Ubiquity::CsvDataRemap.new(record).unordered_hash if record.present?}
      Book.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      BookContribution.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present? }
      ConferenceItem.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      Dataset.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      Image.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      Report.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      GenericWork.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      Exhibition.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      ThesisOrDissertation.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}
      TimeBasedMedia.find_each {|record| @all_records << Ubiquity::CsvDataRemap.new(record).unordered_hash  if record.present?}

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

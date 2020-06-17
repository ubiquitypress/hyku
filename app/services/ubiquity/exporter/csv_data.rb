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

    attr_accessor :all_data, :all_records, :cname_or_original_url, :csv_header, :all_csv_headers

    def initialize(cname_or_original_url)
      @all_records = []
      @all_data = []
      @all_csv_headers = []
      @cname_or_original_url = cname_or_original_url
    end

    def fetch_all_record
      switch_account_tenant
      puts "====== Remapping and exporting db and generating CSV  ====="

      to_csv
    end

    def csv_header(csv_header_array)
      puts "=== starting resorting csv headers from remappedmodels=="
      sorted_header = []

      #resort using ordering by suffix eg creator_isni_1 comes before creator_isni_2
      all_keys =  csv_header_array && csv_header_array.sort_by{ |name| [name[/\d+/].to_i, name] }
      Ubiquity::Exporter::CsvDataRemap::CSV_HEARDERS_ORDER.each {|k| all_keys.select {|e| sorted_header << e if e.start_with? k} }

      puts "=== finished resorting csv headers from remappedmodels=="

      sorted_header.uniq
    end

    def export_all_csv_data(batch = nil)
      all_csv_headers

      batch = batch.presence || work_type_count
      puts "batch size for all-db #{batch}"

      data = ActiveFedora::SolrService.query("id:* AND fq:#{work_types_filter}", { start: batch.first, rows: batch.size})
      puts "data #{data}"
      new_data = data.lazy.map do |item|
        hash = item.to_h
        remapped_data   = Ubiquity::Exporter::CsvDataRemap.new(hash)
        @all_csv_headers << remapped_data.csv_headers
        remapped_data.unordered_hash
       end.force

       puts "=== finished remapping models=="

       new_data

    end

    def work_types_filter
      work_list =  Ubiquity::SharedMethods.tenant_work_list('university-demo.localhost').join(',')
      "{!terms f=has_model_ssim}#{work_list}"
    end

    def work_type_count
      all_records_count = ActiveFedora::SolrService.instance.conn.get("select", params: { q: "id:*",  fq: work_types_filter, rows: 0 })

      total_records = all_records_count['response']['numFound']
      total_records_array = (0..(total_records - 1)).to_a
    end

    def to_csv
      array_of_csv = []
      array_of_hash_remapped_data = []
      @collected_csv_header = []

      work_type_count.each_slice(1000).with_index.map do |value, index|
         new_index = index - 1  if index !=  0;
         #
         #fetch and remap data for csv export
         array_of_hash_remapped_data <<  export_all_csv_data(value)
         @collected_csv_header << @all_csv_headers.flatten.uniq
       end

       flat_data = array_of_hash_remapped_data.flatten
       puts "flattened-remapped data #{flat_data}"
       #Generate csv for export
       array_of_csv <<  csv_generation(flat_data)
       array_of_csv.first
     end

     def csv_generation(array_of_hash_remapped_data)
       puts "array_of_hash_remapped_data #{array_of_hash_remapped_data}"

       sorted_header = csv_header( @collected_csv_header.flatten.uniq)
       puts "sorted-header #{sorted_header}"
       puts "=== starting to generate csv using  remapped models=="

       csv = CSV.generate(headers: true) do |csv|
         csv << sorted_header
         array_of_hash_remapped_data.lazy.each do |hash|
           csv << hash.values_at(*sorted_header)
         end
       end

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

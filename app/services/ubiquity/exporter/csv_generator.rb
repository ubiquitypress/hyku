#You can export all record in the database by calling
# Ubiquity::CsvGenerator.new.export_database_as_remapped_data
#
#You can export the metadata of a single model by calling
#
#Ubiquity::CsvGenerator.new.export_remap_model('Article')

module Ubiquity
  class Exporter::CsvGenerator
    attr_accessor :db_record_count, :model_record_count, :cname_or_original_url

    def initialize(cname_or_original_url = nil)
      @cname_or_original_url = cname_or_original_url
    end

    def export_database_as_remapped_data
      gather_record
    end

    def gather_record
      puts "sako #{cname_or_original_url}"
      @all_data ||= Ubiquity::Exporter::CsvData.new(cname_or_original_url).fetch_all_record
      @db_record_count ||= @all_data.all_records.length
      @all_data.all_records
    end

    def merged_headers(csv_data_object)
      sorted_header = []
      all_keys = csv_data_object.lazy.flat_map(&:keys).force.uniq.compact
      all_keys = all_keys.sort_by{ |name| [name[/\d+/].to_i] }
      Ubiquity::Exporter::CsvDataRemap::CSV_HEARDERS_ORDER.each {|k| all_keys.select {|e| sorted_header << e if e.start_with? k} }
      sorted_header.uniq
    end

    def export_remap_model(klass)
      model_klass = klass.constantize
      @model_record_count = model_klass.count
      model_klass.to_csv
    end

    def self.export_model(klass)
      klass.capitalize.constantize.to_csv_2
    end

  end
end

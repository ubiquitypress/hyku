#You can export all record in the database by calling
# Ubiquity::CsvGenerator.new.export_database_as_remapped_data
#
#You can export the metadata of a single model by calling
#
#Ubiquity::CsvGenerator.new.export_remap_model('Article')

module Ubiquity
  class CsvGenerator
    DEFAULT_WORKS = [Article, Book, BookContribution, ConferenceItem, Dataset, ExhibitionItem, Image, Report, ThesisOrDissertation, TimeBasedMedia, GenericWork].freeze
    attr_accessor :db_record_count, :model_record_count

    #use with regular_export
    #"admin_set_id"
    def self.csv_header
      removed_keys =  Ubiquity::CsvDataRemap::UN_NEEDED_KEYS
      dataset = Dataset.attribute_names - removed_keys
      conference_item = ConferenceItem.attribute_names - removed_keys
      header_keys = dataset.concat(conference_item).uniq
      header_keys.unshift("id")
      header_keys.push('files')

    end

   #use with csv_header
    def self.regular_export
      csv = CSV.generate(headers: true) do |csv|
        csv << csv_header
        DEFAULT_WORKS.each do |klass|
            csv << klass.csv_data
        end
      end
    end

    def export_database_as_remapped_data
      @csv_data_object ||= gather_record
      headers ||= merged_headers(@csv_data_object)
      sorted_header = headers #.sort
      csv = CSV.generate(headers: true) do |csv|
        csv << sorted_header
        @csv_data_object.each do |hash|
          csv << hash.values_at(*sorted_header)
        end

      end
    end

    def gather_record
      @all_data ||= Ubiquity::CsvData.new.fetch_all_record
      @db_record_count ||= @all_data.all_records.length
      @all_data.all_records
    end

    def merged_headers(csv_data_object)
      sorted_header = []
      all_keys = csv_data_object.flat_map(&:keys).uniq
      all_keys = all_keys.sort_by{ |name| [name[/\d+/].to_i, name] }

      Ubiquity::CsvDataRemap::CSV_HEARDERS_ORDER.each {|k| all_keys.select {|e| sorted_header << e if e.start_with? k} }
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

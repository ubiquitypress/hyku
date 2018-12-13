#You can export all record in the database by calling
# Ubiquity::CsvGenerator.new.export_database_as_remapped_data
#
#You can export the metadata of a single model by calling
#
#Ubiquity::CsvGenerator.new.export_remap_model('Article')

module Ubiquity
  class CsvGenerator
    DEFAULT_WORKS = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork].freeze
    attr_accessor :db_record_count, :model_record_count

    #use with regular_export
    def self.csv_header
      removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
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
          klass.all.each do |object|
            #get_csv_data comes from csv_export_util module
            csv << object.get_csv_data
          end
        end
      end
    end

    def export_database_as_remapped_data
      @csv_data_object ||= gather_record
      headers ||= merged_headers(@csv_data_object)
      sorted_header = headers.sort
      csv = CSV.generate(headers: true) do |csv|
        csv << sorted_header
        @csv_data_object.all_records.each do |hash|
          row = sorted_header.map do |key|
            new_values = []
            new_values << hash.dig(key)
            new_values.join(',')
          end
          csv << row
        end

      end
    end

    def gather_record
      @all_data ||= Ubiquity::CsvData.new.fetch_all_record
      @db_record_count ||= @all_data.all_records.length
      @all_data
    end

    def merged_headers(csv_data_object)
      csv_data_object.all_records.map {|hash| hash.keys}.flatten.uniq
    end

    def export_remap_model(klass)
      model_klass = klass.constantize
      @model_record_count = model_klass.count
      model_klass.to_csv_2
    end

    def self.export_model(klass)
      klass.capitalize.constantize.to_csv
    end

  end
end

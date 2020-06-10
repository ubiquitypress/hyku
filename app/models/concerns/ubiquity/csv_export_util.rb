module Ubiquity
  module CsvExportUtil
    extend ActiveSupport::Concern

    def csv_hash
      Ubiquity::Exporter::CsvDataRemap.new(self.to_solr).unordered_hash
    end

    class_methods do

      def regular_header
         removed_keys = Ubiquity::Exporter::CsvDataRemap::UN_NEEDED_KEYS
         header_keys = self.attribute_names - removed_keys
         header_keys.unshift("id")
         header_keys.push('files')
       end

       def csv_header(csv_exporter_object)
         puts "=== starting resorting csv headers from remappedmodels=="

         sorted_header = []
         all_keys = csv_exporter_object.lazy.flat_map(&:keys).force.uniq.compact
         #resort using ordering by suffix eg creator_isni_1 comes before creator_isni_2
         all_keys = all_keys.sort_by{ |name| [name[/\d+/].to_i, name] }
         Ubiquity::Exporter::CsvDataRemap::CSV_HEARDERS_ORDER.each {|k| all_keys.select {|e| sorted_header << e if e.start_with? k} }

         puts "=== finished resorting csv headers from remappedmodels=="

         sorted_header.uniq
       end

       def csv_data
         puts "=== starting remapping models=="
         data ||=  ActiveFedora::SolrService.query("id:* AND has_model_ssim:#{ancestors.first}", { rows: 50000})
         new_data = data.lazy.map do |item|
           hash = item.to_h
           Ubiquity::Exporter::CsvDataRemap.new(hash).unordered_hash
         end.force

         puts "=== finished remapping models=="

         new_data
       end

        def to_csv
          array_of_hash_remapped_data ||= csv_data
          headers ||= csv_header(array_of_hash_remapped_data)
          sorted_header = headers
          puts "=== starting to generate csv using  remapped models=="

          csv = CSV.generate(headers: true) do |csv|
            csv << sorted_header
            csv_data.lazy.each do |hash|
              csv << hash.values_at(*sorted_header)
            end
          end
        end

        def to_csv_2
          CSV.generate do |csv|
            removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
            header_keys = self.attribute_names - removed_keys
            header_keys.unshift("id")
            header_keys.push('files')
            csv << header_keys
            all.each do |object|
              file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
              files = file_names.join(',')
              object.attributes.merge({files: files})
              csv << object.attributes.values_at(*header_keys)
            end
          end
        end

    end
  end
end

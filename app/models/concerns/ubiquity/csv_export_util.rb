module Ubiquity
  module CsvExportUtil
    extend ActiveSupport::Concern

    def csv_hash
      Ubiquity::CsvDataRemap.new(self).new_data
    end

    #mainly remapping array values to have pipe as as seperator
    def get_csv_data
      self.class.regular_header.map do |key|
        value = self.send(key)

        if  (value != key && value.present? && value.class == String)
          value
        elsif ((value != key && value.present? && value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          value.join('||').strip

        elsif (value != key && value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          #problem displays <ActiveTriples::Relation:0x007f1f147e6ca8>
          #when just value is returned
          value.first
        end

        file_names = self.file_sets.map { |file| file.title.first} if self.file_sets.present?
        files = file_names.join('||') if file_names.present?
        files = '' if file_names.blank?
        self.attributes.merge({files: files})

      end
    end

    class_methods do

      def regular_header
         removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
         header_keys = self.attribute_names - removed_keys
         #header_keys = klass.attribute_names - removed_keys
         header_keys.unshift("id")
         header_keys.push('files')
       end

     def csv_header(csv_exporter_object)
       csv_exporter_object.map {|hash| hash.keys}.flatten.uniq
     end

     def csv_data
       #find_each do |object|
        data ||= all.map do |object|
          #object.get_csv_data
          object.csv_hash
        end
        data
      end

      def to_csv_2
        array_of_hash_remapped_data ||= csv_data
        headers ||= csv_header(array_of_hash_remapped_data)
        sorted_header = headers.sort
        csv = CSV.generate(headers: true) do |csv|
          #works
          csv << sorted_header

          array_of_hash_remapped_data.each do |hash|
            row = sorted_header.map do |key|
              new_values = []
              new_values << hash.dig(key)
              new_values.join(',')
            end
            csv << row
          end
        end

      end

     def to_csv
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
     end #closes to_csv

    end

  end
end

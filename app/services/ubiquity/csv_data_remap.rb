module Ubiquity

  class CsvDataRemap
    attr_accessor :data, :new_data
    UN_NEEDED_KEYS = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]

    def initialize(object=nil)
       if object.present?
        @data = object
        remap_array_fields_name(object)
       end
    end

    def remap_array_fields_name(record)
      new_attributes  = record.attributes.except!(*UN_NEEDED_KEYS)
      @data_hash = new_attributes
      @hash = {}
      add_files(record)
      @data_hash.each_with_index do |(key, value), index|
        @hash[key] = ''  if (value.blank?)
        populate_single_fields(key, value) if (@data_hash[key].present? && (@data_hash[key].class == String) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        remap_json_fields(value) if (@data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        remap_array_fields(key, value)  if (@data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        @new_data = @hash

      end
      self
    end

    private

    def populate_single_fields(key, value)
      if value.present?
        @hash[key] = value
      end
    end

    def populate_json(key, value)
      if value.present?
        @hash[key] = value.first
      end
    end

    def remap_array_fields(key, value)
        value.each_with_index do |item, index|
          key_name = ("#{key}_#{index + 1}")
          @hash[key_name] = item
        end
    end

    def remap_json_fields(value)
      value =  JSON.parse(value.first)
      value.each_with_index do |hash, index|
        loop_over_hash(hash, index)
      end
    end

    def loop_over_hash(hash, index)
      hash.each do |key, value|
        key_name = ("#{key}_#{index + 1}")
        @hash[key_name] = value
      end
    end

    def add_files(object)
      if object.file_sets.present?
        object.file_sets.each_with_index do |file, index|
          key_name = ("file_#{index + 1}")
          titles = []
          #a single file can have multiple title
          file.title.each_with_index do |title, i|
            titles |= [title]
          end
          @hash[key_name] = titles.join(',')
        end
      else
          @hash['file'] = ''
      end
    end

  end
end

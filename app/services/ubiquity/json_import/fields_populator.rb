module Ubiquity
  class JsonImport::FieldsPopulator
   attr_accessor :key, :val, :index, :work_instance, :attributes_hash, :data_hash
    def initialize(work_instance, data_hash, attributes_hash, key, vals, index = nil)
      @work_instance = work_instance
      @attributes_hash = attributes_hash
      @data_hash = data_hash
      @key = key
      @val = val
      @index = index
    end

    def  populate_array_field #(key, val, index)
      if ( (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? @key) && (@work_instance.send(@key).class == ActiveTriples::Relation) )
        create_or_skip_work_metadata('array', @key)
      end
      @work_instance
    end

    def populate_json_field  #(key, val)
      if ( (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key)  && (not val.class == String) )
        create_or_skip_work_metadata('json', key)
      end
      @work_instance
    end

    def populate_single_fields  #(key, val)
      if ( (@work_instance.send(key).class != ActiveTriples::Relation) && (val.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        create_or_skip_work_metadata('string', key)
      end
      @work_instance
    end

    def create_or_skip_work_metadata(type, key)
      puts "populating metadata"
      populate_work_values(type, key)
      @work_instance
    end

    def populate_work_values(type, key)
      if type == 'string'
        puts "populating metadata string fields"
        @attributes_hash[key] = @data_hash[key]
      elsif type == 'array'
        puts "populating metadata array fields"
        value = (@data_hash[key].present? ? @data_hash[key].split('||') : [])
        @attributes_hash[key] = value
      elsif type == 'json'
        puts "populating metadata json fields"
        @attributes_hash[key] = [@data_hash[key].to_json]
      end
      @work_instance
    end


  end
end

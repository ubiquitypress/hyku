module Ubiquity

  class CsvExporter
    DEFAULT_WORKS = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork].freeze

    UN_NEEDED_KEYS = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]

    attr_accessor :article, :book, :book_contribution, :conference_item,
                :dataset, :image, :report, :generic_work,
                :article_row, :article_head, :dataset_row, :dataset_head,
                :conference_item_head, :conference_item_row,
                :all_data,:all_headers, :all_rows, :all_records


    def initialize
      switch_account_tenant
      @all_data = []
      DEFAULT_WORKS.each do |model_klass|
        #@article ||= model_klass.all if model_klass == Article
        #@book ||=  model_klass.all if model_klass == Book
        #@book_contribution ||=  model_klass.all if model_klass == BookContribution
        @all_data << @conference_item ||=  model_klass.all if model_klass == ConferenceItem
        @all_data << @dataset ||= model_klass.all if model_klass == Dataset
        ##@image ||= model_klass.all if model_klass == Image
        #@report ||= model_klass.all if model_klass == Report
        #@generic_work ||= model_klass.all if model_klass == GenericWork
      end

     @article_row = []
     @article_head = []

     @all_headers = []
     @all_rows = []
     @all_records = []

    end

    def populate_rows_and_headers
      switch_account_tenant
      #@article.each do |record|
        #remap_array_fields_name(record)
      #end

      #@dataset.each do |record|
        #remap_array_fields_name(record)
    #  end

     data =   @all_data.flatten.compact
     data.each do |record|
        remap_array_fields_name(record)
      end
      self
    end


    def remap_array_fields_name(record)
      method_header_name = "#{record.class.to_s.underscore}_head"
      method_row_name = "#{record.class.to_s.underscore}_row"
      @header_method = self.send(method_header_name.to_sym)
      @row_method = self.send(method_row_name.to_sym)
      @header_method = [] if @header_method.class == String || @header_method.nil?
      @row_method = [] if @row_method.class == String || @row_method.nil?
      new_attributes  = record.attributes.except!(*UN_NEEDED_KEYS)
      data_hash = new_attributes
      @hash = {}

      data_hash.each_with_index do |(key, value), index|

        #key_name = ("#{key}_#{index}")  if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        #puts "key #{key_name}"
        #puts "value #{value}"
        puts "head #{@header_method.inspect}"
        puts "row_w #{@row_method.inspect}"


        @all_headers |= [key] unless (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @all_headers |= [key] if value.class == NilClass

        @hash.merge({key => value}) if (data_hash[key].present? && (data_hash[key].class == String) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        @hash.merge({key => ''})  if value.class == NilClass
        @hash.merge({key => value.first}) if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        @header_method << key if value.class == NilClass
        #@header_method << key_name  if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @header_method << key  if ( data_hash[key].present? && (data_hash[key].class == String) || (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        #string class
        @row_method << value if (data_hash[key].present? && (data_hash[key].class == String) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        @all_rows << value if (data_hash[key].present? && (data_hash[key].class == String) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        #array field
        #@row_method << value  if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        remap_array(key, value)  if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        #json fields
        @row_method << value.first if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @all_rows << value.first if (data_hash[key].present? && (record.send(key).respond_to? :length) && (not value.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        @row_method << '' if value.class == NilClass
        @all_rows << '' if value.class == NilClass

        self.send("#{method_header_name}=", @header_method)
        self.send("#{method_row_name}=", @row_method)

        @all_records << @hash

      end

      puts "dakeys #{data_hash}"
      puts "datahas #{data_hash.keys.length}"
    end

    def remap_array(key, value)
      if value.length > 1
        value.each_with_index do |item, index|
        key_name = ("#{key}_#{index + 1}")
          @header_method <<  key_name
          @all_headers |= [key_name]

           @row_method << item
           @all_rows << item
           @hash.merge({key_name => item})
        end
      else
        @header_method << key
        @all_headers |= [key]

        @row_method << value.first
        @all_rows << value.first

        @hash.merge({key => value.first})

      end
    end

    private

    def switch_account_tenant
      #tenant_uuid = Apartment::Tenant.current
      #if tenant_uuid.present?
        #tenant = Account.where(tenant: tenant_uuid).first
        #tenant_name = tenant.cname if tenant.present?
        #AccountElevator.switch!("#{tenant_name}") if tenant_name.present?
      #else
        AccountElevator.switch!('library.localhost')
      #end
    end

    def header_row
      removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
      header_keys = self.attributes_names - removed_keys
      header_keys.unshift("id")
      header_keys.push('files')
    end

    def article_header
       []
    end

    def book_header
      header = []
    end

    def book_contribution_header
      header = []
    end

    def conference_item_header
      header = []
    end

    def dataset_header
      header = []
    end

    def image_header
      header = []
    end

    def report_header
      header = []
    end

    def generic_work_header
      header = []
    end

    def article_ro
    end

    def book_row
    end

    def book_contribution_row
    end

    def conference_item_row
    end

    def dataset_header_row
    end

    def image_header_row
    end

    def report_header_row
    end

    def generic_work_header_row
    end


    def attributes_row
      #object.attributes.except!(*removed_keys)
    end

  end
end

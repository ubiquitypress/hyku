# Ubiquity::CsvDownloader.run
module Ubiquity
  class CsvDownloader #< ActiveFedora::Base
    def self.export_database
      #tenant_name= Account.pluck(:cname).first
      #https://github.com/ubiquitypress/hyku/blob/master/app/models/account.rb#L76
      tenant_uuid = Apartment::Tenant.current
      tenant = Account.where(tenant: tenant_uuid).first
      tenant_name = tenant.cname
      AccountElevator.switch!("#{tenant_name}")
      csv_data = []
      #model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]
      #model_class = [Dataset, ConferenceItem]
      model_class = [Article]

      model_class.each {|klass| csv_data << klass.to_csv_3}
      #model_class.each_with_index {|klass, index| csv_data << model_class[index].to_csv_try}
      csv_data.join(',')

      #model_class.each {|klass| klass.render_csv}


      #k = model_class.map {|klass| klass.to_csv_4}
      #puts "kilo #{k}"
      #k.join(',')

    end

    def self.export_database_2
      tenant_uuid = Apartment::Tenant.current
      tenant = Account.where(tenant: tenant_uuid).first
      tenant_name = tenant.cname
      AccountElevator.switch!("#{tenant_name}")
      model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]

      removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]

      model_class.each do |model|
        header_keys = model.attribute_names - removed_keys
        header_keys.unshift("id")
        header_keys.push('files')

         model.find_each do |object|
           file_names = object.file_sets.map { |file| file.title.first} if object.file_sets.present?
           object.attributes.merge!({"files" => file_names})

           needed_attributes = object.attributes.except(*removed_keys)

           header_keys.map do |key|

           end  #closes headers

         end #closes moled find_each
      end  #closes model_class


    end #closes export_database_2

    DEFAULT_WORKS = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork]



    def self.csv_data
        #find_each do |object|
        #all.map do |object|
        data = []
        DEFAULT_WORKS.each do |klass|
          klass.all.each do |object|
            data << object.get_csv_data
          end
        end
        data.compact
    end

    #winner
    def self.csv_header
      removed_keys = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",  "version", "label", "relative_path", "import_url", "based_near", "identifier", "access_control_id", "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id", "bibliographic_citation", "state",  "creator_search"]
      #header_keys = self.attribute_names - removed_keys
      #header_keys.unshift("id")
      #header_keys.push('files')
      #article = Article.attribute_names - removed_keys

      dataset = Dataset.attribute_names - removed_keys
      conference_item = ConferenceItem.attribute_names - removed_keys
      header_keys = dataset.concat(conference_item).uniq
      header_keys.unshift("id")
      header_keys.push('files')

    end

  #winner
    def self.ha
      csv = CSV.generate(headers: true) do |csv|
        #works
        csv << csv_header
        DEFAULT_WORKS.each do |klass|
          klass.all.each do |object|
            csv << object.get_csv_data
          end
        end  #closes default
      end
    end

    def self.no
      #new test with head array
      head = []
      csv = CSV.generate(headers: true) do |csv|
        #works
        #csv << csv_header
        #testing with head array
        csv << head.uniq
        DEFAULT_WORKS.each do |klass|
          #testing wth head array
          head |= [klass.csv_header]
          klass.all.each do |object|
            csv << object.get_csv_data
          end
        end  #closes default
      end
    end


    def self.export_models(klass=DEFAULT_WORKS)
      #klass.map {|model| export_csv(model)}
      x = ''
      klass.each {|model| x << export_csv(model)}
      x
    end

    def self.export_mo(klass=DEFAULT_WORKS)
      klass.each do |model|
        to_csv_final(model)
      end
    end

    def self.export_csv(model)
      csv = CSV.generate(headers: true) do |csv|
        csv << model.csv_header
        #model.csv_data.each {|row| csv << row}
        self.csv_data.each {|row| csv << row}
      end
      #csv << model.csv_header
      #model.csv_data.each {|row| puts row}

    end

    def get_csv_data
      self.class.csv_header(object).map do |key|
        puts "nama #{self.send(key)}" if key == "id"
        @id = key if key == "id"
        @object ||= ActiveFedora::Base.send('find', @id)
        #self.send(key)
        #value = self.send(key)
        @object.send(key)
        if  (value.present? && value.class == String)
          [key]
        elsif (value.present? && (value.class == ActiveTriples::Relation || value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          [value.join('||').strip]
        elsif (value.present? && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key) )
          value.to_a
        end
      end
    end




  end ## closes class CsvDownloader

end

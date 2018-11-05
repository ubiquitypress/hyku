module Ubiquity

  class JsonImporter
    attr_reader :ubiquity_model_class

    def initialize(data)
      if data.class == Hash
        data = [data]
      end

      @data = data

      @data_id  = data.first.delete('id') || data.first.delete(:id)
      @tenant = data.first.delete('tenant') || data.first.delete(:tenant)
      @domain = data.first.delete('domain') || data.first.delete(:domain)

      @tenant_domain = @tenant + '.' + @domain
      @data_hash = HashWithIndifferentAccess.new(data.first)
      @file = @data_hash[:file]
      @ubiquity_model_class = @data_hash["type"].constantize
      @work_instance = model_instance
    end

    def run
      AccountElevator.switch!("#{@tenant_domain}")
      email = Hyrax.config.batch_user_key
      @user = User.where(email: @work_instance.depositor).first || User.batch_user #||  User.create(email: email, password: 'abcdefgh',  password_confirmation: 'abcdefgh')
      @work_instance.attributes.each do |key, val|
        populate_array_field(key, val)
        populate_json_field(key, val)
        populate_single_fields(key, val)
      end
      @work_instance.save!
      attach_files
      @work_instance
    end

    private

    def model_instance
      AccountElevator.switch!("#{@tenant_domain}")
      if work = ubiquity_model_class.where(id: @data_id).first || ubiquity_model_class.where(title:@data_hash[:title]).first
        work
      else
        return ubiquity_model_class.new(id: @data_id)  if @data_id.present?
        ubiquity_model_class.new
      end

      rescue ActiveFedora::ObjectNotFoundError
        return ubiquity_model_class.new(id: @data_id)  if @data_id.present?
        ubiquity_model_class.new
    end

    def  populate_array_field(key, val)
      if (@data_hash[key].present? && (@work_instance.send(key).respond_to? :length) && (not val.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @work_instance.send("#{key}=", @data_hash[key].split(','))
      end
    end

    def populate_json_field(key, val)
      if (@data_hash[key].present? && (@work_instance.send(key).respond_to? :length) && (not val.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
         process_json_value(key)
        @work_instance.send("#{key}=", [@data_hash[key].to_json])
      end
    end

    #`remove_hash_keys_with_empty_and_nil_values'
    # undefined method `reject' for #<String:0x0055c27cb68a70
    #all_models_virtual_fields.rb:96:
    def process_json_value(key)
      group_field_key = "#{key}_group"
      record = JSON.parse(@data_hash[key])
      @work_instance.send("#{group_field_key}=", record)
    end

    def populate_single_fields(key, val)
      if (@data_hash[key].present? && (@data_hash[key].class == String) && (not val.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @work_instance.send("#{key}=", @data_hash[key])
      end
    end

    def create_file
    AccountElevator.switch!("#{@tenant_domain}")
      if @file =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
        create_file_from_url
      else
        create_file_directly
      end
    end

    def create_file_directly
      temp_file = Tempfile.new(@file)
      file_name = @file
      io = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: file_name)
      #An activerecord model so return nil when record not found
      temp_file.close
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_file_from_url
      temp_file = open(@file)
      file_name = File.basename(@file)
      io = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: file_name)
      temp_file.close
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_hyrax_uploaded_file(file_io, file_name)
      fetch_or_create_file ||= Hyrax::UploadedFile.where(file: file_name).first  || Hyrax::UploadedFile.create(file: file_io, user: @user)
      @hyrax_uploaded_file = [fetch_or_create_file]
      @hyrax_uploaded_file
    end

    def attach_files
      AccountElevator.switch!("#{@tenant_domain}")
      create_file

     #Note that @hyrax_uploaded_file.first.file returns Hyrax::UploadedFileUploader object
     #Also @hyrax_uploaded_file.first.file.file returns a CarrierWave::SanitizedFile object
     #and @hyrax_uploaded_file.first.file.file.filename returns the the filename in carrierwave
     if check_work_has_existing_file_title.present?
       is_file_in_work = check_work_has_existing_file_title.include? @hyrax_uploaded_file.first.file.file.filename
     else
       is_file_in_work = false
     end

     #pass both to AttachFilesToWorkJob
      if @work_instance.present? && @hyrax_uploaded_file.present? &&  (is_file_in_work == false)
        AttachFilesToWorkJob.perform_later(@work_instance, @hyrax_uploaded_file)
      end
    end

    def check_work_has_existing_file_title
      if @work_instance.file_sets.present?
        @work_instance.file_sets.map { |file_set| file_set.title.first }
      end
    end
    
  end
end

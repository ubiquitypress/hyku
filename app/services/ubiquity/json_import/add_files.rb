module Ubiquity
  class JsonImport::AddFiles
    attr_accessor :file, :tenant_domain, :work_instance
    def initialize(file, tenant_domain, work_instance)
      @file = file
      @tenant_domain = tenant_domain
      @work_instance = work_instance
    end

    def attach_files
      AccountElevator.switch!("#{@tenant_domain}")
      #create_file
      create_file_from_array

      #Note that @hyrax_uploaded_file.first.file returns Hyrax::UploadedFileUploader object
      #Also @hyrax_uploaded_file.first.file.file returns a CarrierWave::SanitizedFile object
      #and @hyrax_uploaded_file.first.file.file.filename returns the the filename in carrierwave
      #
      #pass both to AttachFilesToWorkJob
      if @file.class == String && @work_instance.present? && @hyrax_uploaded_file.present?
        $stdout.puts "Attaching files to work"
        AttachFilesToWorkJob.perform_later(@work_instance, @hyrax_uploaded_file)
      elsif @file.class == Array && @work_instance.present? && @hyrax_uploaded_file.present?
        $stdout.puts "Attaching array of hash files to work #{@hyrax_uploaded_file.inspect}"
        AttachFilesToWorkViaJsonImporterJob.perform_later(@work_instance, @hyrax_uploaded_file)
      end
    end

    def create_file_from_array
      @hyrax_uploaded_file = []
      if @file.present? && @file.class == String
        file_array = @file.split('||')
        create_multiple_files(file_array)
      elsif @file.present? && @file.class == Array
        create_multiple_files_from_array_of_hash(@file)
      end
    end

    def create_multiple_files(file_array)
      file_array.each do |file|
        uploaded_file = create_file(file)
        @hyrax_uploaded_file << uploaded_file
      end
      @hyrax_uploaded_file.compact!
      avoid_duplicates_when_file_title_exist_in_work
    end

    def create_multiple_files_from_array_of_hash(file_array)
      file_array.each do |hash|
        uploaded_file = create_file(hash["path"])
        @hyrax_uploaded_file << {hash["visibility"] => uploaded_file} if uploaded_file.present?
      end
      @hyrax_uploaded_file.reject! {|h| h.values.first == nil}
      avoid_duplicates_when_file_title_exist_in_work
    end

    def create_file(file)
      if file.present? && file =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
        $stdout.puts "creating file from url"
        create_file_from_url(file)
      elsif file.present?
        $stdout.puts "creating file"
        create_file_directly(file)
      end
    rescue Errno::ENOENT => e
      $stdout.puts "creating-file #{file } thre an error for #{e}"
    end

    def create_file_directly(file)
      file = File.new(File.expand_path(file))
      file_name = File.basename(file.path)
      io = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: file_name)
      #An activerecord model so return nil when record not found
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_file_from_url(file)
      $stdout.puts "file url #{file}"
      temp_file = create_tempfile_from_url(file)
      file_name = File.basename(file)
      io = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: file_name)
      temp_file.close
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_tempfile_from_url(file_url)
      data = open(file_url)
      if data.class == StringIO
        create_tempfile_from_stringio(file_url)
      elsif data.class == Tempfile
        #this is a  tempfile
         data
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "#{e} for this url #{file_url}"
    end

    def create_tempfile_from_stringio(file_url)
      url = file_url
      file_name = url.split('/').last
      file = Tempfile.new(file_name)
      stringIo = open(url)
      file.binmode
      file.write stringIo.read
      file
    end

    def create_hyrax_uploaded_file(file_io, file_name)
      puts "creating hyrax_uploaded_file this happens before adding the files to the work"
      AccountElevator.switch!("#{@tenant_domain}")
      fetch_or_create_file ||= Hyrax::UploadedFile.where(file: file_name).first  || Hyrax::UploadedFile.create(file: file_io, user: @user)
    end

    private

    def avoid_duplicates_when_file_title_exist_in_work
      if @file.class == String
        new_files_titles = check_if_file_titles_are_new
        return  @hyrax_uploaded_file.clear if  @hyrax_uploaded_file.first.file.file.filename == new_files_titles
        @hyrax_uploaded_file
      elsif @file.class == Array
        remove_nil_hash_from_array
      end
    end

    def remove_nil_hash_from_array
      new_files_titles = check_if_file_titles_are_new
      hyrax_uploaded_objects = @hyrax_uploaded_file.map { |hash| hash.values.first}
      if new_files_titles.present?
        hyrax_uploads = hyrax_uploaded_objects.map {|carrierwave_object| carrierwave_object if new_files_titles.include?(carrierwave_object.file.file.filename)}
        @hyrax_uploaded_file.reject! {|hash| not hyrax_uploads.include?(hash.values.first) }
      else
        @hyrax_uploaded_file
      end
    end

    def check_if_file_titles_are_new
      if @file.present? && @file.class == String && check_work_has_existing_file_title.present?
        imported_files_titles = [@hyrax_uploaded_file.first.file.file.filename]
        #get the union and the difference to get the file titles that are new
        (check_work_has_existing_file_title - imported_files_titles) | (imported_files_titles - check_work_has_existing_file_title)
      elsif @file.present? && @file.class == Array && check_work_has_existing_file_title.present?
        hyrax_uploaded_objects = @hyrax_uploaded_file.map { |hash| hash.values.first}
        imported_files_titles = hyrax_uploaded_objects.map {|carrierwave_object| carrierwave_object.file.file.filename}
        (check_work_has_existing_file_title - imported_files_titles) | (imported_files_titles - check_work_has_existing_file_title)
      else
        []
      end
    end

    def check_work_has_existing_file_title
      if @work_instance != Collection && @work_instance.try(:file_sets).try(:present?)
        @work_instance.file_sets.map { |file_set| file_set.title.first }
      end
    end

  end
end

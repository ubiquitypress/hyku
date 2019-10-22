module Ubiquity
  class LoadFedoraToSolr
    attr_accessor :file_path, :file_content , :data, :work_object, :files_objects, :tenant_name,
               :thumbnail_object, :representatuve_object

    def initialize(work_uri, files_uri,  tenant_name=nil)
      AccountElevator.switch!(tenant_name)
      @tenant_name = tenant_name
      @work_uri = work_uri
      @files_uri = files_uri
    end

    def run
      AccountElevator.switch!(tenant_name)
      create_work_object
      create_file_objects
      set_thumbnail_and_representative_media
      save_work_to_solr
    end

    def create_work_object
      @work_object = ActiveFedora::Base.from_uri(@work_uri, nil)
      rescue URI::InvalidURIError => e
       puts "exception is #{e}"
    end

    def create_file_objects
      @files_objects =  @files_uri.map do |url|
        puts "url #{url}"
        ActiveFedora::Base.from_uri(url, nil)
      end
      rescue URI::InvalidURIError => e
       puts "exception is #{e}"
    end

    def set_thumbnail_and_representative_media
      @files_objects.each do |file_set|
         if @work_object.thumbnail_id == file_set.try(:id)
           @thumbnail_object =  file_set
         end

         if @work_object.representative_id == file_set.try(:id)
          @representative_object =  file_set
         end
      end

    end

    def save_work_to_solr
      if @work_object.class != FileSet && @work_object.try(:file_sets).try(:present?)
        @work_object.thumbnail = @thumbnail_object
        @work_object.representative = @representatuve_object
        @work_object.ordered_members.clear
        @work_object.ordered_members.concat(@files_objects)
      end
      @work_object.save(validate: false)

      @files_objects.map {|file| file.save(validate: false)}  if  @work_object.try(:file_sets).try(:present?)

    rescue ActiveFedora::AssociationTypeMismatch, ActiveFedora::RecordInvalid, Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused  => e
         puts "error saving #{e}"
    end

  end
end

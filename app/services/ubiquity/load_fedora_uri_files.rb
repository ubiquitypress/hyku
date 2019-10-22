module Ubiquity
  class  LoadFedoraUriFiles
    attr_accessor :file_path, :file_content , :data, :tenant_name
    def initialize(file_name=nil, tenant_name=nil, skip_number=nil)
      @tenant_name = tenant_name
      @skip_number = skip_number || 0
      if file_name.present?
        @file_path = Rails.root.join('lib', 'uri_json', "#{file_name}").to_s
        @file_content = File.read(@file_path)
        @data = JSON.parse(@file_content)
      end
    end

    def loop_over_data
      if @data.present?
        AccountElevator.switch!(tenant_name)
        new_data = @data.shift(@skip_number)
        puts "first #{new_data} records skipped"
        @data.lazy.each do |hash|
          work_uri = hash.keys.first
          files_uri = hash.values.flatten
          #AddFromRdfUriToSolrJob.perform_later(work_uri, files_uri, tenant_name)
          Ubiquity::LoadFedoraToSolr.new(work_uri, files_uri, tenant_name).run
        end
      end

    end

  end
end

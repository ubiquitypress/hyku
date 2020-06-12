class UbiquityExporterJob < ActiveJob::Base
  #queue_as :csv_exporter
  def perform(tenant_name, export_type, requester_id)
    model_list =  Ubiquity::SharedMethods.tenant_work_list(tenant_name) #Hyrax.config.curation_concerns

    if  'all_database'.downcase == export_type
      puts "inside-all"
      csv_generator = Ubiquity::Exporter::CsvGenerator.new(tenant_name)
      csv_data = csv_generator.export_database_as_remapped_data
      orchestrator  = Ubiquity::Exporter::CsvExportOrchestrator.new(csv_data: csv_data, csv_filename: export_type, tenant_name: tenant_name, requester: requester_id)
      orchestrator.upload_to_s3
      puts "upload_to-s3 exporting all"
      orchestrator.send_download_ready_notification
      orchestrator.save_to_redis
      puts "notification-sent all"

    elsif model_list.include?(export_type.constantize)
      puts "inside-model"
      csv_data = Ubiquity::Exporter::CsvGenerator.new(tenant_name).export_remap_model(export_type)
      orchestrator  = Ubiquity::Exporter::CsvExportOrchestrator.new(csv_data: csv_data, csv_filename: export_type, tenant_name: tenant_name, requester: requester_id)
      orchestrator.upload_to_s3
      puts "upload_to-s3 exporting #{export_type}"
      orchestrator.send_download_ready_notification
      orchestrator.save_to_redis
      puts "notification-sent"
    else
      puts "Nothing exported daaa"
    end

  end

end

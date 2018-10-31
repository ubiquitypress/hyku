# You call it directly by entering the container, run
# rails console
#From the rails console run
# UbiquityCsvImporterJob.perform_async('library.localhost', './lib/assets/csv_test.csv', './lib/assets/batch-upload-test/')

class UbiquityCsvImporterJob
  include Sidekiq::Worker
  include ActiveJobTenant
  sidekiq_options queue: 'ubiquity_csv'

  def perform(hostname, csv_file, files_directory)
    if hostname && (csv_file && File.exist?(csv_file)) && files_directory
      AccountElevator.switch!("#{hostname}")
      size = ::Importer::CSVImporter.new(csv_file, files_directory).import_all
      puts "Imported #{size} records."
    else
      $stderr.puts 'On or more of the following is missing: hostname or csv file or file directory path is missing.'
    end
  end
end

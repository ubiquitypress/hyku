# You call it directly by entering the container, run
# rails console
#From the rails console run
#a = Sample
#note we are not inheriting from active_job, hence perform_async is not an active_job method but a sidekiq method
#b = UbiquityJsonImporterJob.perform_async(a)
#
class UbiquityJsonImporterJob
  include Sidekiq::Worker
  sidekiq_options queue: 'ubiquity_json_importer'

  def perform(data)
    Ubiquity::JsonImporter.new(data).run
  end
end

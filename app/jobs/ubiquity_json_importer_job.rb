# You call it directly by entering the container, run
# rails console
#From the rails console run
#a = 'your json data'
#b = UbiquityJsonImporterJob.perform_later(a)


class UbiquityJsonImporterJob
  include Sidekiq::Worker
  sidekiq_options queue: 'ubiquity_json_importer'

  def perform(data)
    Ubiquity::JsonImporter.new(data).run
  end

end

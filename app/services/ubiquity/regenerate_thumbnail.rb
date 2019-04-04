module Ubiquity
  class RegenerateThumbnail
    attr_accessor :tenant, :work_id, :model_name

    def initialize(tenant: , work_id: nil, model_name: nil)
      @work_id = work_id
      @model_name = model_name
      @tenant = tenant
    end

    def run
      if model_name.present?
        renegerate_work_thumbnails_for_model_class
      elsif work_id.present?
        renegerate_specific_work_thumbnail
      elsif model_name.blank? && work_id.blank?
        regenerate_all_thumbnails
      end
    end

    private

    def renegerate_specific_work_thumbnail
      AccountElevator.switch!(tenant)
      work = ActiveFedora::Base.find(work_id)
      puts " Regenerating thumbnail for #{work.class} work with id #{work_id}"

      if work.thumbnail.present?
        file_set = work.thumbnail

        #file_idwork_identifier for a Hydra::PCDM::File
        fedora_pdcm_file = file_set.original_file
        CreateDerivativesJob.perform_later(file_set, fedora_pdcm_file.id)
      end
    end

    def regenerate_all_thumbnails
      puts " Regenerating all thumbnail for all works"
      model_class = [Article, Book, BookContribution, ConferenceItem, Dataset, Image, Report, GenericWork, Collection]
      AccountElevator.switch!(tenant)
      model_class.each do |model|
        loop_over_records(model)
      end

    end

    def renegerate_work_thumbnails_for_model_class
      puts " Generating all thumbnail for all works of type #{model_name}"
      if model_name.present?
        model = model_name.classify.constantize
        AccountElevator.switch!(tenant)
        loop_over_records(model)
      end
    end

    def loop_over_records(model)
      model.find_each do |model_instance|
        if model_instance.thumbnail.present?
           file_set =  model_instance.thumbnail
           #file_id identifier for a Hydra::PCDM::File
           fedora_pdcm_file = file_set.original_file
           CreateDerivativesJob.perform_later(file_set, fedora_pdcm_file.id)
           sleep 2
        end
      end
    end

  end
end

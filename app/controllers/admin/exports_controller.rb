module Admin
  class ExportsController < AdminController
    layout 'dashboard'
    def index
    end

    def export_database
      csv_generator = Ubiquity::CsvGenerator.new
      data = csv_generator.export_database_as_remapped_data
      respond_to do |format|
        format.csv { send_data data, filename: "#{current_account.cname}_metadata.csv" }
      end
    end

    def export_remap_model
      model = params['model']
      #example of exporting jist a single model class eg dataset
      data = Ubiquity::CsvGenerator.new.export_remap_model(model)
      respond_to do |format|
        format.csv { send_data data, filename: "#{current_account.cname}_#{model}_metadata.csv" }
      end
    end

    def export_model
      model = params['model']
      data = Ubiquity::CsvGenerator.regular_export
      respond_to do |format|
        format.csv {render plain: data, content_type: 'text/plain'}
      end
    end


  end
end

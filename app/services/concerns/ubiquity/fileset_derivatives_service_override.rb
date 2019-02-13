module Ubiquity
  module  FilesetDerivativesServiceOverride
    private

    def create_office_document_derivatives(filename)
      puts "docx-override-used"
      Hydra::Derivatives::DocumentDerivatives.create(filename,
                                                      outputs: [{
                                                        label: :thumbnail, format: 'jpg',
                                                        size: '200x150>',
                                                        url: derivative_url('thumbnail')
                                                      }])
      extract_full_text(filename, uri)
    end

  end
end

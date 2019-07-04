module Ubiquity
  module FileSetVersionUpdateContent
    include ActiveSupport::Concern

    def update_content(file, relation = :original_file)
      hyrax_uploaded_file = Hyrax::UploadedFile.create(file: file)
      IngestJob.perform_later(wrapper!(file: hyrax_uploaded_file, relation: relation), notification: true)
    end
  end
end

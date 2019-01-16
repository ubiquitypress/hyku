module Hyku
  class ManifestEnabledWorkShowPresenter < Hyrax::WorkShowPresenter
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyku::FileSetPresenter

    delegate :extent, :rendering_ids, :isni, :institution, :org_unit, :refereed, :doi, :isbn, :issn, :eissn,
             :funder, :fndr_project_ref, :add_info,
             :journal_title, :issue, :volume, :pagination, :article_num, :project_name, :rights_holder,
             :official_link, :place_of_publication, :series_name, :edition, :abstract, :version,
             :event_title, :event_date, :event_location, :book_title, :editor,
             :alternate_identifier, :related_identifier, :media, :related_exhibition, :related_exhibition_date,
             :library_of_congress_classification,
             to: :solr_document

    def manifest_url
      manifest_helper.polymorphic_url([:manifest, self])
    end

    # IIIF rendering linking property for inclusion in the manifest
    #
    # @return [Array] array of rendering hashes
    def sequence_rendering
      renderings = []
      if solr_document.rendering_ids.present?
        solr_document.rendering_ids.each do |file_set_id|
          renderings << build_rendering(file_set_id)
        end
      end
      renderings.flatten
    end

    # IIIF metadata for inclusion in the manifest
    #
    # @return [Array] array of metadata hashes
    def manifest_metadata
      metadata = []
      metadata_fields.each do |field|
        metadata << {
          'label' => field.to_s.humanize.capitalize,
          'value' => get_metadata_value(field)
        }
      end
      metadata
    end

    # assumes there can only be one doi
    def doi_from_identifier
      doi_regex = %r{10\.\d{4,9}\/[-._;()\/:A-Z0-9]+}i
      doi = extract_from_identifier(doi_regex)
      doi.join if doi
    end

    # unlike doi, there can be multiple isbns
    def isbns
      isbn_regex = /((?:ISBN[- ]*13|ISBN[- ]*10|)\s*97[89][ -]*\d{1,5}[ -]*\d{1,7}[ -]*\d{1,6}[ -]*\d)|
                    ((?:[0-9][-]*){9}[ -]*[xX])|(^(?:[0-9][-]*){10}$)/x
      isbns = extract_from_identifier(isbn_regex)
      isbns.flatten.compact if isbns
    end

    def model
      solr_document['has_model_ssim'].first
    end

    def readable_model
      model.split(/(?=[A-Z])/).join(' ')
    end

    def no_associated_file?
      return true if solr_document['file_set_ids_ssim'].blank?
      false
    end

    def edit_access
      solr_document['edit_access_person_ssim']
    end

    def date_published
      date = solr_document['date_published_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_published_tesim'] # kept for backward compatibility
    end

    def date_accepted
      date = solr_document['date_accepted_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_accepted_tesim']
    end

    def date_submitted
      date = solr_document['date_submitted_dtsim']
      return formatted_date(date) if date.present?
      solr_document['date_submitted_tesim']
    end

   #Added because there was no way to acces file_set_presenter from a  collection page or the search page.
   #represengter_presenter which returns a file_set_presenter is nil in those places too
    def thumbnail_presenter
      return nil if thumbnail_id.blank?
      @thumbnail_presenter ||=
        begin
          result = member_presenters([thumbnail_id]).first
          puts " #{result.inspect}"
          return nil if result.try(:id) == id
          if result.respond_to?(:thumbnail_presenter)
            result.thumbnail_presenter
          else
            result
          end
        end
    end

    private


      # `dtsim` fields are in format "2017-01-01T00:00:00Z"
      # we save "01" instead of no value if a user does not enter a month or/and day in order to have a compatible date,
      # thus avoid displaying default day and month here.
      # see 'all_models_virtual_fields' `#transform_date_group`
      def formatted_date(date)
        return Date.parse(date.first).strftime("%F") unless date.first[(8..9)] == "01"
        return Date.parse(date.first).strftime("%Y-%m") if date.first[(5..9)] != "01-01"
        Date.parse(date.first).strftime("%Y")
      end

      def extract_from_identifier(rgx)
        if solr_document['identifier_tesim'].present?
          ref = solr_document['identifier_tesim'].map do |str|
            str.scan(rgx)
          end
        end
        ref
      end

      def manifest_helper
        @manifest_helper ||= ManifestHelper.new(request.base_url)
      end

      # Build a rendering hash
      #
      # @return [Hash] rendering
      def build_rendering(file_set_id)
        query_for_rendering(file_set_id).map do |x|
          label = x['label_ssi'] ? ": #{x.fetch('label_ssi')}" : ''
          {
            '@id' => Hyrax::Engine.routes.url_helpers.download_url(x.fetch(ActiveFedora.id_field), host: request.host),
            'format' => x.fetch('mime_type_ssi') ? x.fetch('mime_type_ssi') : 'unknown mime type',
            'label' => 'Download whole resource' + label
          }
        end
      end

      # Query for the properties to create a rendering
      #
      # @return [SolrResult] query result
      def query_for_rendering(file_set_id)
        ActiveFedora::SolrService.query("id:#{file_set_id}",
                                        fl: [ActiveFedora.id_field, 'label_ssi', 'mime_type_ssi'],
                                        rows: 1)
      end

      # Retrieve the required fields from the Form class. Derive the Form class name from the Model name.
      #   The class should exist, but it may not if different namespaces are being used.
      #   If it does not exist, rescue and return an empty Array.
      #
      # @return [Array] required fields
      def metadata_fields
        ns = "Hyrax"
        "#{ns}::#{model}Form".constantize.required_fields
      rescue StandardError
        []
      end

      # Get the metadata value(s).
      #
      # @return [Array] field value(s)
      def get_metadata_value(field)
        Array.wrap(send(field))
      end
  end
end

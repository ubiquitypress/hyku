module Ubiquity

  class Exporter::CsvDataRemap
    attr_accessor :data, :ordered_data, :retained_object_attributes, :unordered_hash, :data_hash
    UN_NEEDED_KEYS = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",
                     "label", "relative_path", "import_url", "based_near", "identifier",  "access_control_id",
                     "representative_id", "thumbnail_id", "embargo_id", "lease_id",
                      "bibliographic_citation", "state",  "creator_search", "doi_options", "draft_doi",
                      "disable_draft_doi", "version_number", 'depositor', 'file_availability'
                     ]

    CSV_HEARDERS_ORDER = %w(id date_uploaded date_modified file visibility  embargo_end_date  visibility_after_embargo lease_end_date visibility_after_lease collection
                        work_type resource_type title alternative_title creator contributor abstract date_published material_media duration institution organisational_unit project_name
                        funder funder_project_reference event_title event_date event_location series_name book_title editor journal_title alternative_journal_title volume edition version
                        issue pagination article_number publisher place_of_publication isbn issn eissn current_he_institution date_accepted date_submitted official_url
                        related_url related_exhibition related_exhibition_date language license rights_statement rights_holder doi qualification_name qualification_level
                        alternate_identifier related_identifier peer_reviewed keyword dewey library_of_congress_classification additional_information
                        migration_id collection_id is_included_in degree irb_number irb_status location outcome participant reading_level
                        challenged photo_caption photo_description buy_book page_display_order_number admin_set
                       )

  def initialize(object=nil)
    if object.present?
      @data = object
      work_attributes =  object.merge!(parse_dates(object))
      @retained_object_attributes = work_attributes
      remap_array_fields_name(object)
    end
  end

  def remap_array_fields_name(record)
      #passed in methods
      @data_hash = rename_hash_keys_to_csv_keys(retained_object_attributes, hash_value_as_csv_keys)
      @unordered_hash  = {}

      add_files(record)
      @data_hash.each_with_index do |(key, value), index|
        # (not value.class == ActiveTriples::Relation )
        #
        puts "================================ keya  =============== #{key}"

        @unordered_hash[key] = ''  if (value.blank?) &&  (not value.class == Array ) #(not  ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include?(key) )

        #ActiveTriples::Relatio
        #
        populate_single_fields(key, value) if  value.present? && (@data_hash[key].present? && (@data_hash[key].class == String || @data_hash[key].class == DateTime) && (not value.class == Array) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        remap_json_fields(value) if value.present? && (@data_hash[key].present?  && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key)) && (not value.class == String) && (value.class != DateTime)  # &&(record.send(key).respond_to? :length)

        #@data_hash[key].to_a.class == Arra
        #
        remap_array_fields(key, value)  if value.present? && (@data_hash[key].present? && (not value.class == String) && (value.class != DateTime) && @data_hash[key].class == Array && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
      end
      self
    end

    def rename_hash_keys_to_csv_keys(main_hash, hash_with_new_keys)
      common_keys = hash_with_new_keys.keys &  main_hash.keys
      puts "common_keys #{common_keys}"
      new_hash = main_hash.slice(*common_keys)
      common_keys.each {|term|   new_hash[hash_with_new_keys[term]] = new_hash.delete(term) if hash_with_new_keys.keys.include?(term) && new_hash.keys.include?(term)}
      new_hash
    end

    private

    def parse_dates(object)
      embargo_release_date = object["embargo_release_date_dtsi"].presence && DateTime.parse(object["embargo_release_date_dtsi"]).try(:strftime, "%Y-%m-%d")
      lease_expiration_date = object["lease_expiration_date_dtsi"].presence && DateTime.parse(object["lease_expiration_date_dtsi"]).try(:strftime, "%Y-%m-%d")
      date_uploaded = object["date_uploaded_dtsi"].presence && DateTime.parse(object["date_uploaded_dtsi"]).try(:strftime, "%Y-%m-%d")
      date_modified = object["date_modified_dtsi"].presence && DateTime.parse(object["date_modified_dtsi"]).try(:strftime, "%Y-%m-%d")

      {'embargo_release_date_dtsi' => embargo_release_date, 'lease_expiration_date_dtsi' => lease_expiration_date,

         'date_uploaded_dtsi' => date_uploaded, 'date_modified_dtsi' => date_modified
       }
    end

    def populate_single_fields(key, value)
      if value.present?
        @unordered_hash[key] = value
      end
    end

    def populate_json(key, value)
      if value.present?
        @unordered_hash[key] = value.first
      end
    end

    def remap_array_fields(key, value)
        list_of_array_used_as_single_felds = ['title', 'volume', 'version', 'alt_title', 'admin_set', 'work_type']
        value.each_with_index do |item, index|
          key_name = ("#{key}_#{index + 1}")  if list_of_array_used_as_single_felds.exclude?(key)
          key_name = key if list_of_array_used_as_single_felds.include?(key)
          puts "#{key_name} - #{value} -#{item.inspect}"

          @unordered_hash[key_name] = item
        end
    end

    def remap_json_fields(value)
      new_value = give_json_fields_right_csv_headers(value)
      new_value.each_with_index do |hash, index|
        loop_over_hash(hash, index)
      end
    end

    def give_json_fields_right_csv_headers(data)
      data_array_hash =  JSON.parse(data.first)
      data_array_hash.map do |data_hash|
        new_hash = data_hash.except('creator_position', 'contributor_position', 'editor_position')
        rename_hash_keys_to_csv_keys(new_hash, hash_value_as_json_csv_keys)
      end
    end

    def loop_over_hash(hash, index)
      new_hash = hash.except("creator_institutional_relationship", "contributor_institutional_relationship",
         "editor_institutional_relationship", "alternate_identifier_position", "related_identifier_position")
      new_hash.each do |key, value|
        key_name = ("#{key}_#{index + 1}")
        @unordered_hash[key_name] = value
      end
      transform_institutional_relationship(hash, index)

    end

    def transform_institutional_relationship(hash, index)
      institutional_relationship = hash.slice("creator_institutional_relationship", "contributor_institutional_relationship", "editor_institutional_relationship")
      if institutional_relationship.present?
        array_institutional_relationship =  institutional_relationship.values.flatten
        field_key = institutional_relationship.keys.first.split('_').first
        array_institutional_relationship.each do |item|
          #remove empty space between words
          if item.present?
            join_words = item.downcase.gsub(' ', '')
            key_name = "#{field_key}_#{join_words}_#{index + 1}"
            @unordered_hash[key_name] = 'true'
          end
        end
      end
    end

    def add_files(object)
      get_file_ids = object["file_set_ids_ssim"]
      id_strings = get_file_ids.presence && get_file_ids.join(',')

       #  if object.file_sets.present?
       if id_strings.present?
         file_sets = ActiveFedora::Base.where("{!terms f=id}#{id_strings}")
         #object.file_sets.each_with_index do |file, index|
         file_sets.each_with_index do |file, index|
           key_name = ("file_#{index + 1}")
           titles = []
           puts "adding file names #{file.try(:title)}"
           #a single file can have multiple title
           file.title.each_with_index do |title, i|
             titles |= [title]
           end
           @unordered_hash[key_name] = titles.join(',')
         end
      end
    end

    def hash_value_as_csv_keys
      {
       "id" => "id", "date_uploaded_dtsi" => "date_uploaded", "date_modified_dtsi" => "date_modified", "visibility_ssi" => "visibility",
       "embargo_release_date_dtsi" => "embargo_end_date", "visibility_after_embargo_ssim" => "visibility_after_embargo", "visibility_after_lease_ssim" => "visibility_after_lease",
       "lease_expiration_date_dtsi" => "lease_end_date", "collection_id_sim" => "collections", "has_model_ssim" => "work_type", "resource_type_tesim" => "resource_type",
       "title_tesim" => "title", "alt_title_tesim" => 'alternative_title', "creator_tesim" => "creator", "contributor_tesim" => "contributor", "abstract_tesim" => "abstract",
      "date_published_si" => "date_published", "media_tesim" => "media",  "duration_tesim" => "duration", "institution_tesim" => "institution", 'org_unit_tesim' => 'organisational_unit',
      "project_name_tesim" => "project_name",  "funder_tesim" => "funder", "fndr_project_ref_tesim" => 'funder_project_reference', "event_title_tesim" => "event_title",
      "event_date_tesim" => "event_date", "event_location_tesim" => "event_location", "series_name_tesim" => "series_name", "book_title_tesim" => "book_title", "editor_tesim" => "editor",
      "journal_title_tesim" => "journal_title", "alternative_journal_title_tesim" => "alternative_journal_title", "volume_tesim" => "volume", "edition_tesim" => "edition",
      "version_tesim" => "version",  "issue_tesim" => "issue", "pagination_tesim" => "pagination", "article_num_tesim" => 'article_number', "publisher_tesim" => "publisher",
      "place_of_publication_tesim" => "place_of_publication", "isbn_tesim" => "isbn", "issn_tesim" => "issn", "eissn_tesim" => "eissn", "current_he_institution_tesim" => "current_he_institution",
      "date_accepted_tesim" => "date_accepted", "date_published_tesim" => "date_published", "official_link_tesim" => "official_url", "related_url_tesim" => "related_url",
      "related_exhibition_tesim" => "related_exhibition", "related_exhibition_date_tesim" => "related_exhibition_date", "language_tesim" => "language",
      "license_tesim" => "license", "rights_statement_tesim" => "rights_statement", "rights_holder_tesim" => "rights_holder", "doi_tesim" => "doi",
      "qualification_name_tesim" => "qualification_name", "qualification_level_tesim" => "qualification_level",  "alternate_identifier_tesim" => "alternate_identifier_id",
      "related_identifier_tesim" => "related_identifier_id", "refereed_tesim" => 'peer_reviewed', "dewey_tesim" => "dewey",
      "library_of_congress_classification_tesim" =>  "library_of_congress_classification", "add_info_tesim" => 'additional_information',
      "migration_id_sim" => "migration_id", "is_included_in_tesim" => "is_included_in", "degree_tesim" => "degree",
      "irb_number_tesim" => "irb_number", "irb_status_tesim" => "irb_status", "location_tesim" => "locations", "outcome_tesim" => "outcome",
      "participant_tesim" => "participant", "reading_level_tesim" => "reading_level",  "challenged_tesim" => "challenged",
      "photo_caption_tesim" => "photo_caption",  "photo_description_tesim" => "photo_description", "buy_book_tesim" => "buy_book",
      "page_display_order_number_tesim" => "page_display_order_number", "admin_set_tesim" => "admin_set"
      }

    end

    def hash_value_as_json_csv_keys
      {
        'relation_type' => 'related_identifier_relationship',
        'related_identifier' => 'related_identifier_id',
        'editor_organization_name' => 'editor_organisation_name',
        'creator_organization_name' => 'creator_organisation_name',
        'contributor_organization_name' => 'contributor_organisation_name'
     }
    end

  end
end

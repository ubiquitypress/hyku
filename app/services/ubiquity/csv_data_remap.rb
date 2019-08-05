module Ubiquity

  class CsvDataRemap
    attr_accessor :data, :ordered_data, :retained_object_attributes, :unordered_hash
    UN_NEEDED_KEYS = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",
                     "label", "relative_path", "import_url", "based_near", "identifier",  "access_control_id",
                     "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id",
                      "bibliographic_citation", "state",  "creator_search", "doi_options", "draft_doi",
                      "disable_draft_doi", "version_number", "series_name", 'depositor', 'file_availability'
                     ]

    CSV_HEARDERS_ORDER = %w(id date_uploaded date_modified file visibility  embargo_end_date  visibility_after_embargo lease_end_date visibility_after_lease collection
                        work_type resource_type title alternative_title creator contributor abstract date_published material_media duration institution organisational_unit project_name
                        funder funder_project_reference event_title event_date event_location series_name book_title editor journal_title volume edition version
                        issue pagination article_number publisher place_of_publication isbn issn eissn current_he_institution date_accepted date_submitted official_url
                        related_url related_exhibition related_exhibition_date language license rights_statement rights_holder doi qualification_name qualification_level
                        alternate_identifier related_identifier peer_reviewed keyword dewey library_of_congress_classification additional_information)

    def initialize(object=nil)
       if object.present?
        @data = object
        add_more_keys_attributes_hash = {'embargo_end_date' => object.embargo_release_date.try(:strftime, "%Y-%m-%d"), 'lease_end_date' => object.lease_expiration_date.try(:strftime, "%Y-%m-%d"),
           'visibility' => object.visibility, 'visibility_after_embargo' => object.visibility_after_embargo, 'work_type' => object.class.to_s,
           'visibility_after_lease' => object.visibility_after_lease, 'collection' => object.member_of_collections.first.try(:id),
           'date_uploaded' => object.date_uploaded.try(:strftime, "%Y-%m-%d"), 'date_modified' => object.date_modified.try(:strftime, "%Y-%m-%d")
        }
        work_attributes = object.attributes.merge(add_more_keys_attributes_hash)
        @retained_object_attributes = work_attributes.except!(*UN_NEEDED_KEYS)
        remap_array_fields_name(object)
       end
    end

    def remap_array_fields_name(record)
      #passed in methods
      @data_hash = rename_hash_keys_to_csv_keys(retained_object_attributes, hash_value_as_csv_keys)
      @unordered_hash  = {}

      add_files(record)
      @data_hash.each_with_index do |(key, value), index|

        @unordered_hash[key] = ''  if (value.blank?) &&  (not value.class == ActiveTriples::Relation ) #(not  ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include?(key) )

        populate_single_fields(key, value) if  value.present? && (@data_hash[key].present? && (@data_hash[key].class == String || @data_hash[key].class == DateTime) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        remap_json_fields(value) if value.present? && (@data_hash[key].present?  && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key)) && (not value.class == String) && (value.class != DateTime) && (record.send(key).respond_to? :length)

        remap_array_fields(key, value)  if value.present? && (@data_hash[key].present? && (not value.class == String) && (value.class != DateTime) && @data_hash[key].to_a.class == Array && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
      end
      self
    end

    def rename_hash_keys_to_csv_keys(main_hash, hash_with_new_keys)
      common_keys = main_hash.keys & hash_with_new_keys.keys
      common_keys.each {|term| main_hash[hash_with_new_keys[term]] = main_hash.delete(term) if hash_with_new_keys.keys.include?(term) && main_hash.keys.include?(term)}
      main_hash
    end

    private

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
        list_of_array_used_as_single_felds = ['title', 'volume', 'version', 'alt_title']
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
          join_words = item.downcase.gsub(' ', '')
          key_name = "#{field_key}_#{join_words}_#{index + 1}"
          @unordered_hash[key_name] = 'true'
        end
      end
    end

    def add_files(object)
      if object.file_sets.present?
        object.file_sets.each_with_index do |file, index|
          key_name = ("file_url_#{index + 1}")
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
       'official_link' => 'official_url', 'refereed' => 'peer_reviewed',
        'article_num' => 'article_number', 'fndr_project_ref' => 'funder_project_reference',
        'add_info' => 'additional_information', 'file' => 'file_url', 'org_unit' => 'organisational_unit',
        'media' => 'material_media', 'alt_title' => 'alternative_title'
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

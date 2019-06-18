module Ubiquity

  class CsvDataRemap
    attr_accessor :data, :ordered_data, :retained_object_attributes, :unordered_hash
    UN_NEEDED_KEYS = ["head", "tail","proxy_depositor", "on_behalf_of", "arkivo_checksum", "owner",
                     "label", "relative_path", "import_url", "based_near", "identifier",  "access_control_id",
                     "representative_id", "thumbnail_id", "admin_set_id", "embargo_id", "lease_id",
                      "bibliographic_citation", "state",  "creator_search", "doi_options", "draft_doi",
                      "disable_draft_doi", "version_number", "series_name", 'depositor'
                     ]

    CSV_HEARDERS_ORDER = %w(id date_uploaded date_modified file visibility  embargo_end_date  visibility_after_embargo lease_end_date visibility_after_lease collection
                        work_type resource_type title creator contributor doi alternate_identifier version  related_identifier series_name volume edition journal_title
                        book_title issue pagination editor publisher place_of_publication isbn issn eissn article_number material_media date_published date_accepted
                        date_submitted abstract keyword institution organisational_unit peer_reviewed official_url related_url related_exhibition related_exhibition_date
                        project_name funder funder_project_reference additional_information license rights_statement rights_holder language event_title event_date
                        event_location)

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
      #ordered_keys_csv_header = []
      add_files(record)
      @data_hash.each_with_index do |(key, value), index|

        @unordered_hash[key] = ''  if (value.blank?)
        populate_single_fields(key, value) if (@data_hash[key].present? && (@data_hash[key].class == String || @data_hash[key].class == DateTime) && (not value.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))

        remap_json_fields(value) if (@data_hash[key].present?  && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key)) && (not value.class == String) && (value.class != DateTime) && (record.send(key).respond_to? :length)

        remap_array_fields(key, value)  if (@data_hash[key].present? && (not value.class == String) && (value.class != DateTime) && @data_hash[key].to_a.class == Array && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
      end
      self
    end

    def ordered_data
      ordered_keys_csv_header = order_hash_keys_for_csv(unordered_hash)
      @ordered_data = unordered_hash.slice(*ordered_keys_csv_header)
    end

   #They are public methods as they allow me call the methods in the console and sort keys
   def order_hash_keys_for_csv(hash_data)
     hash_for_csv = []
     hash_data = CSV_HEARDERS_ORDER.each_with_object({}) { |k, h| h[k] =  hash_data.keys.select { |e| e.start_with? k } }
     num = CSV_HEARDERS_ORDER.length
     csv_headers = CSV_HEARDERS_ORDER.map.zip(0..num).to_h
     #y = hash_data.keys
     hash_data.sort_by { |k, _| csv_headers[k] }.flat_map(&:last)
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
        value.each_with_index do |item, index|
          key_name = ("#{key}_#{index + 1}")
          puts "#{key_name} - #{value} -#{item.inspect}"

          @unordered_hash[key_name] = item
        end
    end

    def remap_json_fields(value)
      value = give_json_fields_right_csv_headers(value)
      value.each_with_index do |hash, index|
        loop_over_hash(hash, index)
      end
    end

    def give_json_fields_right_csv_headers(data)
      data_array_hash =  JSON.parse(data.first)
      data_array_hash.map do |data_hash|
        rename_hash_keys_to_csv_keys(data_hash, hash_value_as_json_csv_keys)
      end
    end

    def loop_over_hash(hash, index)
      hash.each do |key, value|
        key_name = ("#{key}_#{index + 1}")
        @unordered_hash[key_name] = value
      end
    end

    def add_files(object)
      if object.file_sets.present?
        object.file_sets.each_with_index do |file, index|
          key_name = ("file_#{index + 1}")
          titles = []
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
        'add_info' => 'additional_information', 'file' => 'file_url', 'org_unit' => 'organisation_unit',
        'media' => 'material_media'
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

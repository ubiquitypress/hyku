#Included in all models
#
module Ubiquity
  module ApiUtilityMethods
    extend ActiveSupport::Concern
    def license_for_api
      if self.try(:license).present?
        remap_license
      end
    end

    def rights_statements_for_api
      if self.try(:license).present?
        remap_rights_statement
      end
    end

    def member_of_collections_for_api
      if self.try(:member_of_collections) && self.class != FileSet
        self.member_of_collections.map do |collection_object|
          {uuid: collection_object.id, title: collection_object.title.first}
        end
      end
    end

    def alternate_identifier_for_api
      if self.try(:alternate_identifier) && self.class != FileSet
        remap_alternate_identifier
      end
    end

    def related_identifier_for_api
      if self.try(:related_identifier) && self.class != FileSet
        remap_related_identifier
      end
    end

    def work_filesets_summary_for_api
      if self.try(:file_sets)
        get_file_sets_totals
      end
    end

    private
    #leave it as a public method because it used in other files
    # return false if json == String
    def valid_json?(data)
      !!JSON.parse(data)  if data.class == String
      rescue JSON::ParserError
        false
    end

    def remap_rights_statement
      rights_statement_hash = Hyrax::RightsStatementService.new.select_all_options.to_h
      self.rights_statement.map do |item|
          if rights_statement_hash.key(item)
            {
              name: rights_statement_hash.key(item),
              link: item
            }
          end
        end
      end

      def remap_license
        license_hash = Hyrax::LicenseService.new.select_all_options.to_h
        self.license.map do |item|
          if license_hash.key(item)
            {
              name: license_hash.key(item),
              link: item
            }
          end
        end
      end

      def  remap_alternate_identifier
        if valid_json?(self.alternate_identifier.first)
          alternate_identifier_array = JSON.parse(self.alternate_identifier.first)
          alternate_identifier_array.map do |hash|
            {
              name: hash['alternate_identifier'],
              type: hash['alternate_identifier_type'],
              postion: hash["alternate_identifier_position"].to_i
            }
          end

        end
      end

      def  remap_related_identifier
        if valid_json?(self.related_identifier.first)
          related_identifier_array = JSON.parse(self.related_identifier.first)
          related_identifier_array.map do |hash|
            {
              name: hash['related_identifier'],
              type: hash['related_identifier_type'],
              relationship: hash['relation_type'],
              postion: hash["related_identifier_position"].to_i
            }
          end

        end
      end

      def get_file_sets_totals
        file_count = self.file_sets.count
        #
        #returns hash that group files by their visibility eg {"open"=>2}
        total_summary = self.file_sets.group_by(&:visibility).transform_values(&:count)
        total_summary.merge({total: file_count})
      end

  end
end

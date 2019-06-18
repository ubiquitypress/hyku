module Ubiquity
  module CitationsExportConcern
    include ActiveSupport::Concern

    def fetch_data work
      rif_data_ary = []
      rif_data_ary << "TY  - #{work.human_readable_type}"
      ris_format_keys.each do |ris_key, column|
        if ris_key == 'CR'
          process_create_ary(work, rif_data_ary)
          next
        end
        if ris_key == 'ED'
          process_editor_ary(work, rif_data_ary)
          next
        end
        if ris_key == 'PY'
          value = work.try(column)
          rif_data_ary << "#{ris_key}  - #{value.split('-')[0]}" if value.present?
          next
        end
        if ['SN', 'SP'].include? ris_key
          value = multiple_value_check(work, column)
          rif_data_ary << "#{ris_key}  - #{value}" if value.present?
          next
        end
        value = work.try(column)
        next if value.blank?
        if ris_key == 'KY'
          value.each do |kw_value|
            rif_data_ary << "#{ris_key}  - #{kw_value}"
          end
          next
        end
        value = value.first if value.class.to_s == 'ActiveTriples::Relation'
        rif_data_ary << "#{ris_key}  - #{value}"
      end
      rif_data_ary << "ER  - "
    end

    private

      def multiple_value_check(work, columns)
        result = ''
        columns.each do |column|
          result = work.try(column)
          break if result.present?
        end
        result
      end

      def process_create_ary(work, rif_data_ary)
        creator_json_ary = work.try(:creator)
        return nil if creator_json_ary.blank?
        creator_ary = Ubiquity::ParseJson.new(creator_json_ary.first).creator_for_rif_template
        creator_ary.split('; ').each_with_index do |creator, index|
          rif_data_ary << "A#{index + 1}  - #{creator}"
        end
      end

      def process_editor_ary(work, rif_data_ary)
        editor_json_ary = work.try(:editor)
        return nil if editor_json_ary.blank?
        editor_ary = Ubiquity::ParseJson.new(editor_json_ary.first).editor_for_rif_template
        editor_ary.split('; ').each do |creator|
          rif_data_ary << "ED  - #{creator}"
        end
      end

      def ris_format_keys
        {
          'T1' => :title, 'T2' => :alt_title, 'TI' => :book_title, 'CR' => :creator, 'ED' => :editor, 'AB' => :abstract,
          'DA' => :date_published, 'DO' => :doi, 'JO' => :journal_title, 'LA' => :language, 'N1' => :add_info,
          'KW' => :keyword, 'IS' => :issue, 'PB' => :publisher, 'PP' => :place_of_publication, 'PY' => :date_published,
          'SN' => %i[isbn issn eissn], 'SP' => %i[pagination article_num], 'UR' => :official_link, 'VL' => :volume
        }
      end
  end
end

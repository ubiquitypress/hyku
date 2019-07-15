module Ubiquity
  module CitationsExportConcern
    include ActiveSupport::Concern

    def fetch_data work
      rif_data_ary = []
      rif_data_ary << "TY  - #{rif_work_type(work.resource_type.first)}"
      ris_format_keys.each do |ris_key, column|
        if ris_key == 'T2'
          process_alternate_titles(work, rif_data_ary)
          next
        end
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
        if ris_key == 'KW'
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
        creator_ary = Ubiquity::ParseJson.new(creator_json_ary.first).fetch_value_based_on_key('creator', '; ')
        creator_ary.split('; ').each do |creator|
          rif_data_ary << "AU  - #{creator}"
        end
      end

      def process_alternate_titles(work, rif_data_ary)
        title_array = work.alt_title.to_a
        title_array = title_array.unshift(work.book_title) if work.book_title.present?
        title_array.compact.each do |title|
          rif_data_ary << "T2  - #{title}"
        end
      end

      def rif_work_type(resource_type)
        work_type = resource_type_mapping.select{ |_k, v| v.include?(resource_type) }.keys.first
        work_type || 'GEN'
      end

      def process_editor_ary(work, rif_data_ary)
        editor_json_ary = work.try(:editor)
        return nil if editor_json_ary.blank?
        editor_ary = Ubiquity::ParseJson.new(editor_json_ary.first).fetch_value_based_on_key('editor', '; ')
        editor_ary.split('; ').each do |editor|
          rif_data_ary << "ED  - #{editor}"
        end
      end

      def resource_type_mapping
        {
          "JOUR" => ["Article default Journal article", "Article Book review", "Article Data paper", "Article Editorial", "Article Letter to the editor", "Collection Data paper", "Collection Journal article", "Collection Working paper"],
          "SOUND" => ["Audio", "ExhibitionItem Audio-visual guide", "GenericWork Sound", "TimeBasedMedia Interview (radio, television)", "TimeBasedMedia Musical composition", "TimeBasedMedia Podcast", "Collection Sound"],
          "BOOK" => ["Book default Book", "Book", "Book Grey literature", "Book Working paper", "Collection Book"],
          "DATA" => ["Dataset default Dataset", "Dataset", "Dataset Numerical dataset", "Dataset Geographical dataset", "Collection Database", "Collection Dataset", "Collection Geographical dataset"],
          "THES" => ["Dissertation", "Masters Thesis", "GenericWork Dissertation", "ThesisOrDissertation Doctoral thesis", "ThesisOrDissertation Master's dissertation", "Collection Thesis (doctoral)"],
          "MAP" => ["Map or Cartographic Material", "GenericWork Cartographic material", "Collection Cartographic material"],
          "CHAP" => ["Part of Book", "BookContribution default Book chapter", "BookContribution Book editorial", "Collection Book chapter", "Collection Book editorial"],
          "CONF" => ["Poster", "ConferenceItem Abstract", "ConferenceItem Conference paper (published)", "ConferenceItem default Conference paper (unpublished)", "ConferenceItem Conference poster (published)", "ConferenceItem Conference poster (unpublished)", "ConferenceItem Lecture", "ConferenceItem Presentation", "Collection Conference paper (published)", "Collection Conference paper (unpublished)", "Collection Conference poster (published)", "Collection Conference poster (unpublished)"],
          "RPRT" => ["Report", "Report Policy report", "Report default Research report", "Report Technical report", "Collection Policy report", "Collection Research report", "Collection Technical report"],
          "COMP" => ["Software or Program Code", "GenericWork Software", "Collection Software", "Dataset Software"],
          "VIDEO" => ["Video", "TimeBasedMedia Animation", "TimeBasedMedia Video"],
          "MGZN" => ["Article Magazine article", "Collection Magazine article"],
          "NEWS" => ["Article Newspaper article", "Collection Newspaper article"],
          "MUSIC" => ["GenericWork Musical notation", "Collection Musical notation"],
          "PAT" => ["GenericWork Patent", "Collection Patent"],
          "ELEC" => ["GenericWork Website", "Collection Website"],
          "BLOG" => ["GenericWork Blog post", "Collection Blog post"]
        }
      end

      def ris_format_keys
        {
          'T1' => :title, 'T2' => %i[book_title alt_title], 'CR' => :creator, 'ED' => :editor, 'AB' => :abstract,
          'DA' => :date_published, 'DO' => :doi, 'JO' => :journal_title, 'LA' => :language, 'N1' => :add_info,
          'KW' => :keyword, 'IS' => :issue, 'PB' => :publisher, 'PP' => :place_of_publication, 'PY' => :date_published,
          'SN' => %i[isbn issn eissn], 'SP' => %i[pagination article_num], 'UR' => :official_link, 'VL' => :volume
        }
      end
  end
end

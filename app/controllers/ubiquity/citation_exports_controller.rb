module Ubiquity
  class CitationExportsController < ApplicationController
    def export_to_rif
      puts params[:work_id]
      p '-------------------------'
      work = ActiveFedora::Base.find(params[:work_id])
      text = []
      text << "TY - #{work.human_readable_type}"
      ris_format_keys.each do |ris_key, column|
        next if work.try(column.first).nil?
        value = work.try(column.first)
        value = value.first if value.class.to_s == 'Array'
        text << "#{ris_key}  - #{value}"
      end
      # send_data(text.join("\n"), type: "application/x-endnote-refer", filename: 'trial.rif')
    end

    private

      def ris_format_keys
        {
          'T1' => [:title],
          # '%Q' => [:title, ->(x) { x.drop(1) }], # subtitles
          'AB' => [:abstract],
          'PB' => [:publisher],
          'KY' => [:keyword]
        }
      end
  end
end

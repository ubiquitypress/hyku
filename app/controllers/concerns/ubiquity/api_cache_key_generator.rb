module Ubiquity
  module ApiCacheKeyGenerator
    private

    def get_records_with_pagination_cache_key(data, last_updated_child = nil, user = nil)
        #build_cache_key(data, last_updated_child)
        build_cache_key(data: data, last_updated_child: last_updated_child, user: user)
    end

    def add_filter_by_class_type_with_pagination_cache_key(data, last_updated_child = nil, user = nil)
       #build_cache_key(data, last_updated_child, add_model_name = true )
       build_cache_key(data: data, last_updated_child: last_updated_child, add_model_name: true, user: user )
    end

    def add_filter_by_metadata_field_with_pagination_cache_key(data, metadata_key=nil, last_updated_child = nil, user = nil)
      #build_cache_key(data, last_updated_child, metadata_key)
      build_cache_key(data: data, last_updated_child: last_updated_child, metadata_key: metadata_key, user: user)
    end

    def build_cache_key(data:, last_updated_child:, metadata_key: nil, add_model_name: nil, user: nil)
      timestamp = set_cache_last_modified_time_stamp(data, last_updated_child)
      cname = data['response']['docs'].first['account_cname_tesim'].first
      model_name = data['response']['docs'].first['has_model_ssim'].first.underscore
      record_count = data['response']['numFound']
      if user.present?
        return "auth/multiple/#{cname}/#{user.id}/#{model_name}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.present?
        return "auth/multiple/#{cname}/#{user.id}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.blank? && metadata_key.blank?
        return "auth/multiple/#{cname}/#{user.id}/#{metadata_key}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if metadata_key.present?
      else
        return "multiple/#{cname}/#{model_name}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.present?
        return "multiple/#{cname}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if add_model_name.blank? && metadata_key.blank?
        return "multiple/#{cname}/#{metadata_key}/page-#{page}/per_page-#{limit}/#{timestamp}/#{record_count}" if metadata_key.present?

      end
    end

    def set_cache_last_modified_time_stamp(parent_record, child_record)
      data_updated_time = parent_record['response']['docs'].first['system_modified_dtsi']
      last_child_updated_at = get_last_child_updated_at(child_record) #child_record && child_record.dig('response', 'docs')
      if last_child_updated_at.present?
        child_timestamp = last_child_updated_at.first['system_modified_dtsi']
      else
        child_timestamp = nil
      end
       [data_updated_time, child_timestamp].compact.max
    end

    def get_last_child_updated_at(child_record)
      if child_record.class == ActiveRecord
        child_record.updated_at.utc.try(:iso8601)
      elsif child_record.class == Blacklight::Solr::Response
        child_record.dig('response', 'docs')
      end
    end

  end
end

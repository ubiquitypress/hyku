module Ubiquity
  module SharedSearchHelper

    def parse_json(data)
      JSON.parse(data.first)
    end

    #request_protocol example are http:// and https://
    #request_port examples are 8080
    # call with:
    # generate_work_url('137e67f1-e25b-4a18-8f5c-a885aa168230', 'bl.oar.bl.uk', 'article', '"oar.bl.uk"', 'https://', request_port=nil)
    #
    def generate_work_url(id, tenant, model_class, request_host, request_protocol, request_port=nil)
        work_class = model_class.to_s.underscore.pluralize
        if work_class == "collections"
          set_collection_url(id, tenant, work_class, request_host, request_protocol, request_port)
        else
          set_work_url(id, tenant, work_class, request_host, request_protocol, request_port)
        end
    end

    def get_thumbnail_visibility(file_id, tenant)
      if file_id.present? && tenant.present?
        work =  get_thumbnail_file(file_id, tenant)
        work.thumbnail.try(:visibility)
      end
    end

    def get_thumbnail_label(file_id, tenant)
      if file_id.present? && tenant.present?
        work =  get_thumbnail_file(file_id, tenant)
        work.thumbnail.try(:label)
      end
    end

    def generate_sort_label(sort_value)
      if sort_value.present?
        label_hash = {
         "score_desc_system_create_dtsi_desc" => "relevance",
         "system_create_dtsi_desc" => "date uploaded ▼",
         "system_create_dtsi_asc"  => "date uploaded ▲"
        }.freeze

        split_value = sort_value.split(',')
        new_value = split_value.first.split(' ').join('_') if split_value.size == 1
        label = label_hash[new_value]
        return label if label.present?
        first_part_of_value = split_value.shift.split(' ').join('_') if split_value.size == 2
        second_part_of_value = split_value.first.split(' ').join('_') if split_value.first.present?
        joined_value = first_part_of_value + '_' + second_part_of_value if first_part_of_value.present? && second_part_of_value.present?
        label_hash[joined_value]
      else
        #sometimes sort_value is an empty string when submitiing an empty shared_search form
        #from url paths that don't include /shared_search in such cases uses the default
        "relevance"
      end
    end

    #leads to error of each_with_index when looping over hash because
    #when coming from links like facet params class is ActionController::Parameters
    #but sometimes it is a string
    def turn_params_facet_to_hash
      if params[:f].present?
        return  hash_term = params.dig(:f).try(:to_unsafe_h) if (params.dig(:f).class == ActionController::Parameters)
        return  hash_term = JSON.parse(params[:f]) if params[:f].class == String && !params[:f].blank?
        return  hash_term = params[:f] if params[:f].class == Hash
      end
    end

    def facet_cookie_to_hash
      if cookies[:facet].present?
        JSON.parse(cookies[:facet])
      end
    end

    private

    def get_thumbnail_file(file_id, tenant)
      if file_id.present? && tenant.present?
        AccountElevator.switch!(tenant)
        work ||= ActiveFedora::Base.find(file_id)
        work
      end
    end

    def set_work_url(id, tenant, work_class, request_host, request_protocol, request_port)
      if request_host == 'localhost'
        "#{request_protocol}#{tenant}:#{request_port}/concern/#{work_class}/#{id}?locale=en"
      else
        "#{request_protocol}#{tenant}/concern/#{work_class}/#{id}?locale=en"
      end
    end

    def set_collection_url(id, tenant, work_class, request_host, request_protocol, request_port)
      if request_host == 'localhost'
        "#{request_protocol}#{tenant}:#{request_port}/#{work_class}/#{id}?locale=en"
      else
        "#{request_protocol}#{tenant}/#{work_class}/#{id}?locale=en"
      end
    end

  end
end

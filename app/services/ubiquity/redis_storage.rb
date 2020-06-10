# Usage
#r = Ubiquity::RedisStorage.new(tenant_name: 'library', export_name: 'export_name', requester: 'a@yo.com', download_url: '', successful: '' )

module Ubiquity
  class RedisStorage
    attr_accessor :tenant_name, :export_name, :requester, :successful, :options
    def initialize(tenant_name:, export_name: nil, requester: nil,  options: {})
      @options = options
      @tenant_name = tenant_name
      @export_name = export_name
      @requester = requester
      @successful = options['successful']
    end

    def self.client
      $redis_storage
    end

    def redis_key
      if tenant_name.present? && export_name.present?
        "#{tenant_name}" + '/' + "#{export_name}"
      elsif tenant_name.present?
        tenant_name
      end
    end

    def save
      if redis_key.present?
        $redis_storage && $redis_storage.set(redis_key, json_to_save)
      end
    end

    def update
      if redis_key.present?
        hash_data = get_hash_from_json_in_redis
        attrs = json_to_save(hash_data)
        $redis_storage && $redis_storage.set(redis_key, attrs)
      end
    end

    #takes as value either get_hash_from_json_in_redis or defaul_hash
    def json_to_save(hash = {})
      new_hash = hash.presence || default_hash
      new_hash["current_requester"] = requester
      new_hash["successful"] = successful
      new_hash['tenant_name'] = tenant_name
      new_hash.to_json
    end

    def find_one_as_json #(tenant_name, export_name)
      #$redis_csv_export.hgetall('library')
      if export_name.present? && redis_key.present?
        $redis_storage && $redis_storage.get(redis_key)
      end
    end

    def find_one_as_hash
      json_record = find_one_as_json(tenant_name, export_name)
      hash_value = JSON.parse(json_record)
    end

    def find_all_as_json
      $redis_storage && $redis_storage.keys("#{tenant_name}/*")
    end

    def find_all_as_hash
      records = find_all_as_json
      if records.present?
        return_hash(records)
      end
    end

    def return_hash(data)
      if data.present?
        data.map do |item|
          JSON.parse(item) if item.present?
        end.compact
      end
    end

    def default_hash
      {"current_requester"=> requester, "successful"=> "false", "tenant_name"=> tenant_name,
      "last_error" => " ", "retries_count"=> 0, "date_of_original_request"=>""}
    end

    def get_download_url
       get_hash_from_json_in_redis['download_url']
    end


  end
end

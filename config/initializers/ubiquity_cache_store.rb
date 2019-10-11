
#expected output is similar to  {"host"=>"172.18.0.5", "port"=>6379, "namespace"=>"ubiquitypress"}
config = YAML.load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access
config.merge!({ namespace: 'ubiquitypress'})

redis_config = config.merge(thread_safe: true)

Rails.application.config.cache_store = :redis_store, redis_config #, { expires_in: 90.minutes }

if Rails.env == 'production'

 $redis_cache = Redis::Store.new(
       :host => ENV['REDIS_CACHE_HOST'],
       :port => ENV['REDIS_CACHE_PORT'],
       :namespace => "hyku-cache",
       :db => 0
 )

$redis_storage = Redis::Store.new(
     :host => ENV['REDIS_CACHE_HOST'],
     :port => ENV['REDIS_CACHE_PORT'],
     :namespace => "redis-storage",
    :db => 3
)

 $redis = Redis.new(
   :host => ENV['REDIS_HOST'],
   :port => ENV['REDIS_PORT']
 )
end

class Rack::Attack

  redis_client = Redis::Store.new(:host => ENV['REDIS_CACHE_HOST'],
      :port => ENV['REDIS_CACHE_PORT'], :namespace => "hyku-rack-attack-cache", :db => 1)

  Rack::Attack.cache.store = redis_client

  safelist("safe_host") do |request|
    request.env['HTTP_X_UBIQUITY_VALIDATION'] == ENV['UBIQUITY_VALIDATION']
 end

 blocklist("block_api_access") do |request|
    # Requests are blocked if the return value is truthy
    if request.path.include?'api/v1'
      request.env['HTTP_X_UBIQUITY_VALIDATION'] != ENV['UBIQUITY_VALIDATION']
    end
  end

end

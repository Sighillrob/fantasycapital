redis_url = ENV["REDISCLOUD_URL"] || ENV["OPENREDIS_URL"] || ENV["REDISGREEN_URL"] || ENV["REDISTOGO_URL"] || 'redis://localhost:6379'

Sidekiq.configure_server do |config|
    config.redis = { :url => redis_url, :namespace => 'sidekiq' }
end

Sidekiq.configure_client do |config|
    config.redis = { :url => redis_url, :namespace => 'sidekiq' }
end

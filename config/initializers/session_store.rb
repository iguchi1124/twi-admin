# Be sure to restart your server when you modify this file.

redis_uri = URI(ENV['REDIS_URL'] || 'redis://localhost:6379')
Rails.application.config.session_store :redis_store,
  servers: {
    host: redis_uri.host,
    port: redis_uri.port,
    db: 0,
    namespace: 'session'
  },
  expires_in: 90.minutes

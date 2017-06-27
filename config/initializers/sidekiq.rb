require 'sidekiq'
require 'sidekiq-status'
#
# Sidekiq.configure_client do |config|
#   config.client_middleware do |chain|
#     # accepts :expiration (optional)
#     chain.add Sidekiq::Status::ClientMiddleware, expiration: (60*24).minutes
#   end
# end
#
# Sidekiq.configure_server do |config|
#   config.server_middleware do |chain|
#     # accepts :expiration (optional)
#     chain.add Sidekiq::Status::ServerMiddleware, expiration: (60*24).minutes
#   end
#   config.client_middleware do |chain|
#     # accepts :expiration (optional)
#     chain.add Sidekiq::Status::ClientMiddleware, expiration: (60*24).minutes
#   end
# end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDISTOGO_URL"] }
  config.server_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ServerMiddleware, expiration: (60*24).minutes # default
  end
  config.client_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ClientMiddleware, expiration: (60*24).minutes # default
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDISTOGO_URL"] }
  config.client_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ClientMiddleware, expiration: (60*24).minutes # default
  end
end

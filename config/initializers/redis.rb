# require 'redis'
# # if Rails.env == "development"
# # 	Redis.current = Redis.new(host: ::REDIS_CONFIG['host'], port: ::REDIS_CONFIG['port'])
# # 	Redis.current.select(::REDIS_CONFIG['database'])
# # else
# 	# uri = URI.parse(ENV["REDISTOGO_URL"])
# 	# REDIS = Redis.new(:url => ENV["REDISTOGO_URL"])
# # end
#
# uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6399/")
# REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
# ENV["REDIS_URL"] = ENV["REDISTOGO_URL"]
#
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     # We're in smart spawning mode.
#     Redis.current.client.reconnect if forked
#   end
# end

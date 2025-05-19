max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 3)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch('PORT', 8080)

pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

if ENV.fetch('RAILS_ENV') { 'development' } == 'production'
  workers ENV.fetch('WEB_CONCURRENCY', 1)

  preload_app!

  worker_timeout 60

  worker_shutdown_timeout 30
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

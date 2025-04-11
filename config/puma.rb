# Pumaの設定
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# ポート設定をシンプルに
port        ENV.fetch("PORT") { 8080 }

# プロセス管理
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

if ENV.fetch("RAILS_ENV") { "development" } == "production"
  workers ENV.fetch("WEB_CONCURRENCY") { 1 }
  # preload_app!
end

# 再起動時の設定
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
# スレッド数の設定
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# ポート設定（bindディレクティブは削除）
port ENV.fetch("PORT") { 8080 }

# ポート設定を明示的に
bind "tcp://0.0.0.0:8080"

# 環境設定
environment ENV.fetch("RAILS_ENV") { "production" }

# Railsのリスタートを許可
plugin :tmp_restart

# プロセス管理
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Production環境の設定
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  # ワーカープロセス数
  workers ENV.fetch("WEB_CONCURRENCY") { 1 }
  
  # アプリケーションを事前読み込み
  preload_app!
end

# 再起動時の設定
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
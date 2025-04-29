# Pumaの設定
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# ポート設定
port ENV.fetch("PORT") { 8080 }

# プロセス管理
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# 本番環境の設定
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  # サーバーの物理コア数に基づいてワーカー数を設定
  # CPUコア数の1-2倍が推奨値（メモリに依存）
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  # アプリケーションをプリロード（メモリ効率化とスタートアップ時間短縮）
  preload_app!

  # worker起動のタイムアウト設定
  worker_timeout 60

  # リクエストのタイムアウト設定（秒単位）
  worker_shutdown_timeout 30
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

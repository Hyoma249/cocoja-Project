# 環境変数からスレッド数を取得
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Back4appで使用するポートを設定
port ENV.fetch("PORT", 8080)

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# 本番環境用の追加設定
if ENV['RAILS_ENV'] == 'production'
  # Workerのタイムアウトを設定
  worker_timeout 3600 if ENV.fetch("WEB_CONCURRENCY", 0).to_i > 0

  # プリローダーを有効化
  preload_app!
end
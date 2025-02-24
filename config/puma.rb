# 環境変数からスレッド数を取得
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# 明示的にポート8080を指定
port ENV.fetch("PORT", 8080)

# バインドアドレスを指定（重要）
bind "tcp://0.0.0.0:#{ENV.fetch("PORT", 8080)}"

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Solid Queue plugin
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Enable pidfile if specified
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Production specific settings
if ENV['RAILS_ENV'] == 'production'
  environment ENV.fetch("RAILS_ENV", "production")
  workers ENV.fetch("WEB_CONCURRENCY", 2)
  preload_app!
end
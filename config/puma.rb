# Pumaの設定（メモリ使用量を最小化）
threads 1, 1  # スレッド数を最小限に設定

# ポート設定をシンプルに
port ENV.fetch("PORT") { 8080 }

# プロセス管理
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

if ENV.fetch("RAILS_ENV") { "development" } == "production"
  workers 1  # ワーカー数を1に固定
  preload_app!
end

# メモリリークを減らすための設定
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# 再起動時の設定
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# 定期的なGC実行を設定
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  Thread.new do
    loop do
      sleep 300  # 5分ごと
      GC.start
    end
  end
end
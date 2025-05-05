# Pumaの設定
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 3) # スレッド数を削減
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# ポート設定
port ENV.fetch('PORT', 8080)

# プロセス管理
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

# 本番環境の設定
if ENV.fetch('RAILS_ENV') { 'development' } == 'production'
  # Back4appの限られたリソースに合わせて調整
  workers ENV.fetch('WEB_CONCURRENCY', 1) # ワーカー数を1に削減

  # メモリ最適化のためのプリロード
  preload_app!

  # リソース使用量を減らすためのタイムアウト設定
  worker_timeout 60
  worker_shutdown_timeout 30

  # 低メモリモードを有効化
  low_memory_mode = true if defined?(low_memory_mode)

  # GC設定の最適化
  before_fork do
    GC.compact if defined?(GC.compact)
  end
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# メモリ使用量を監視し、高くなりすぎた場合にGCを強制実行
worker_check_interval 30
on_worker_check do |worker|
  # メモリ使用量が高い場合にGCを強制実行
  if GetProcessMem.new.mb > 300 # 300MBを超えたらGCを実行
    GC.start
  end
end

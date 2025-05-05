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

  before_fork do
    # 古いGCメソッドはエラーになる可能性があるためより汎用的な方法を使用
    GC.start
  end
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# 安全なメモリ監視方法
worker_check_interval 30
on_worker_check do
  begin
    if defined?(GetProcessMem) && GetProcessMem.respond_to?(:new)
      mem = GetProcessMem.new
      if mem.mb > 300 # 300MBを超えたらGCを実行
        GC.start
      end
    end
  rescue => e
    # エラーをキャッチして、アプリケーションのクラッシュを防止
    puts "Memory check error: #{e.message}"
  end
end

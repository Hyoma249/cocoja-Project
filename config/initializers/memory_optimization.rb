# メモリ使用量を最適化するための設定

if Rails.env.production?
  # Rubyのバージョンに依存しない方法でGCパラメータを調整
  # 直接GC定数を設定
  GC::MALLOC_LIMIT = 64 * 1024 * 1024      # 64MB
  GC::MALLOC_LIMIT_MAX = 128 * 1024 * 1024 # 128MB
  GC::OLDMALLOC_LIMIT = 64 * 1024 * 1024   # 64MB
  GC::OLDMALLOC_LIMIT_MAX = 128 * 1024 * 1024 # 128MB

  # GCの間隔を調整
  GC.stress = false
  # 初回GCサイクルの実行
  GC.start

  # 定期的にGCを実行するためのミドルウェア
  class GCMiddleware
    def initialize(app)
      @app = app
      @counter = 0
    end

    def call(env)
      @counter += 1
      if @counter >= 20 # 20リクエストごとにGCを実行
        GC.start
        @counter = 0
      end
      @app.call(env)
    end
  end

  Rails.application.config.middleware.use GCMiddleware

  # メモリ使用状況を監視するロガーを追加
  Rails.logger.info "Memory Optimization: GC settings initialized for Rails #{Rails.version}"

  # メモリ使用量を定期的に出力するための設定（オプション）
  if defined?(GetProcessMem)
    # GetProcessMemが使用可能な場合のみ実行
    begin
      mem = GetProcessMem.new
      Rails.logger.info "Initial Memory Usage: #{mem.mb.round(2)} MB"
    rescue => e
      Rails.logger.warn "Memory tracking failed: #{e.message}"
    end
  end
end

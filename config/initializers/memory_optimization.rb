# メモリ使用量を最適化するための設定

if Rails.env.production?
  # Garbage Collectionの設定最適化
  GC.configure(
    malloc_limit: 64 * 1024 * 1024,      # メモリ割り当て制限を64MBに設定
    malloc_limit_max: 128 * 1024 * 1024, # 最大メモリ割り当て制限を128MBに設定
    oldmalloc_limit: 64 * 1024 * 1024,   # 古い世代のメモリ割り当て制限
    oldmalloc_limit_max: 128 * 1024 * 1024,
    heap_free_slots: 10_000,              # 空きスロットの数
    heap_init_slots: 10_000               # 初期スロット数
  )

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
end

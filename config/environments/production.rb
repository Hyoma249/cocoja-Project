require 'active_support/core_ext/integer/time'

# 本番環境の設定
Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  # キャッシュ設定 - Redisを使用してパフォーマンス向上
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL') { raise 'REDIS_URL environment variable is required' },
    namespace: 'cache',
    expires_in: 1.day,
    compression: true,
    compress_threshold: 1.kilobyte
  }

  # アセット設定
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000, immutable'
  }
  config.assets.compile = true
  config.assets.css_compressor = nil
  config.assets.digest = true
  config.assets.version = '1.0'

  # SSL設定 - Back4Appの環境に最適化
  config.force_ssl = false
  # X-Forwarded-Proto ヘッダーを信頼し、適切に処理
  config.action_controller.default_url_options = { protocol: 'https' }
  # 信頼できるプロキシとして明示的にBack4Appのプロキシを追加
  config.action_dispatch.trusted_proxies = %w[127.0.0.1 ::1].map { |proxy| IPAddr.new(proxy) }
  # X-Forwarded-Proto ヘッダーがhttpsの場合はリダイレクトしない
  config.ssl_options = {
    hsts: { subdomains: true, preload: true, expires: 1.year },
    redirect: {
      exclude: lambda { |request|
        request.get_header('HTTP_X_FORWARDED_PROTO') == 'https' 
      }
    }
  }

  # ログ設定 - デバッグのため詳細なログを出力
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
  config.log_level = :info # 標準のログレベルに設定

  # i18n
  config.i18n.fallbacks = true

  # データベース最適化
  config.active_record.dump_schema_after_migration = false

  # その他の設定
  config.require_master_key = true

  # Action Cable設定
  config.action_cable.disable_request_forgery_protection = false
  config.action_cable.allowed_request_origins = [%r{http://*}, %r{https://*}]
end

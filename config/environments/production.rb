require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  # キャッシュ設定 - Redisを使用してパフォーマンス向上
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL") { raise "REDIS_URL environment variable is required" },
    namespace: "cache",
    expires_in: 1.day,
    compression: true,
    compress_threshold: 1.kilobyte
  }

  # アセット設定
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=31536000, immutable"
  }
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'
  # CDNを使用してアセット配信を高速化
  config.action_controller.asset_host = ENV.fetch("ASSET_HOST") { nil }

  # SSL設定 - リダイレクトループを避けるためfalseに
  config.force_ssl = false
  config.action_controller.default_url_options = { protocol: 'https' }
  config.action_dispatch.trusted_proxies = %w(127.0.0.1 ::1).map { |proxy| IPAddr.new(proxy) }
  config.ssl_options = { redirect: { exclude: -> request { request.get_header('HTTP_X_FORWARDED_PROTO') == 'https' } } }

  # ログ設定 - パフォーマンス向上のため最適化
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", :warn).to_sym

  # i18n
  config.i18n.fallbacks = true

  # データベース最適化
  config.active_record.dump_schema_after_migration = false
  config.active_record.pool = ENV.fetch("RAILS_MAX_THREADS") { 5 }
  # クエリキャッシュを有効化
  config.active_record.query_cache_size = 100

  # その他の設定
  config.require_master_key = true

  # Action Cable設定
  config.action_cable.disable_request_forgery_protection = false
  config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]
end
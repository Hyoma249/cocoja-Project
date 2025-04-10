require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  # キャッシュ設定
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    pool_size: 5,
    pool_timeout: 5
  }

  # アセット設定
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=31536000, immutable"
  }
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'

  # SSL設定
  config.force_ssl = false

  # プロキシ設定の追加
  config.action_dispatch.trusted_proxies = %w(0.0.0.0/0).map { |proxy| IPAddr.new(proxy) }

  # デフォルトURLオプションの設定
  config.action_controller.default_url_options = { protocol: 'https' }

  # ログ設定
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = :warn  # infoからwarnに変更してログ量削減

  # Active Storage - Cloudinaryを使用しているため無効化
  # config.active_storage.service = :local

  # i18n
  config.i18n.fallbacks = true

  # その他の設定
  config.active_record.dump_schema_after_migration = false
  config.require_master_key = true

  # 開発用設定（必要に応じて）
  config.action_cable.disable_request_forgery_protection = false
  config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]

  # パブリックファイルの設定
  config.public_file_server.enabled = true

end
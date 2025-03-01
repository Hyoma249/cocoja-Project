require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = true

  # キャッシュ設定
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  # アセット設定
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'

  # SSL設定
  config.force_ssl = false

  # ログ設定
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = :debug

  # Active Storage
  config.active_storage.service = :local

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

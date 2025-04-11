require "active_support/core_ext/integer/time"

Rails.application.configure do
  # キャッシュの設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  # キャッシュ設定
  config.action_controller.perform_caching = true
  # キャッシュをメモリ効率の良い方法に変更
  config.cache_store = :null_store  # キャッシュを完全に無効化

  # アセットの最適化
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=31536000, immutable"
  }
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # SSL設定
  config.force_ssl = false

  # プロキシ設定の追加
  config.action_dispatch.trusted_proxies = %w(0.0.0.0/0).map { |proxy| IPAddr.new(proxy) }

  # デフォルトURLオプションの設定
  config.action_controller.default_url_options = { protocol: 'https' }

  # ログレベルの調整
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = :info

  # ログ設定の最適化
  config.log_level = :warn  # ログレベルを上げてログ量を削減
  config.logger = ActiveSupport::TaggedLogging.new(
    Logger.new(STDOUT, 
      formatter: proc { |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n" unless severity == "DEBUG"
      }
    )
  )

  # Active Storage - Cloudinaryを使用しているため無効化
  # config.active_storage.service = :local

  # i18n
  config.i18n.fallbacks = true

  # Active Recordの設定
  config.active_record.dump_schema_after_migration = false
  config.active_record.belongs_to_required_by_default = true
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = false

  # ActionCableの無効化（使用していない場合）
  config.action_cable.mount_path = nil
  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]

  # パブリックファイルの設定
  config.public_file_server.enabled = true

end
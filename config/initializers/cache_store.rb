# config/initializers/cache_store.rb
if Rails.env.production?
  Rails.application.configure do
    # Redisのフラグメントキャッシュ設定を最適化
    config.action_controller.perform_caching = true

    # キャッシュの有効期限設定をより細かく制御
    config.active_record.cache_versioning = true

    # バスティング（ダーティキャッシュを避ける）を有効化
    config.active_record.collection_cache_versioning = true
  end
end

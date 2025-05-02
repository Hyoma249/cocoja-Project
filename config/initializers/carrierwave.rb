CarrierWave.configure do |config|
  if Rails.env.production?
    # キャッシュディレクトリの設定
    config.cache_dir = Rails.root.join('tmp/uploads').to_s

    # キャッシュの保存期間設定（任意）
    config.cache_storage = :file
  end
end

CarrierWave.configure do |config|
  if Rails.env.production?
    # 本番環境ではtmpディレクトリを使用（通常は書き込み可能）
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    # または環境変数TMP_DIRを使用
    # config.cache_dir = ENV.fetch('TMP_DIR', '/tmp')
  end
end
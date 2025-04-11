CarrierWave.configure do |config|
  # 明示的にCloudinaryのみを使用するよう指定
  config.cache_storage = :file
end
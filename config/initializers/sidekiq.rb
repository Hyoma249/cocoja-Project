require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  # 環境変数からRedis URLを読み込み
  config.redis = { url: ENV['REDIS_URL'] }
  # スケジュール設定は自動的に読み込まれるため、特別な設定は不要
end

Sidekiq.configure_client do |config|
  # 環境変数からRedis URLを読み込み
  config.redis = { url: ENV['REDIS_URL'] }
end
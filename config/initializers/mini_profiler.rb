# config/initializers/mini_profiler.rb
if defined?(Rack::MiniProfiler)
  # 本番環境でも使用する場合
  Rack::MiniProfiler.config.authorization_mode = :allow_all

  # 特定のURLパスを除外
  Rack::MiniProfiler.config.skip_paths ||= []
  Rack::MiniProfiler.config.skip_paths << '/assets/'
end
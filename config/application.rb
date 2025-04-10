require_relative "boot"

require "rails/all"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.assets.initialize_on_precompile = false
    config.assets.enabled = true
    config.assets.version = '1.0'

    # 追加項目⬇️
    # デフォルト言語を日本語に設定
    config.i18n.default_locale = :ja
    # i18n の翻訳ファイルのパスを追加
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.middleware.insert_before 0, Rack::Logger
    # CSRF保護のオリジンチェックを無効化（HTTP/HTTPS不一致問題を解決）
    config.action_controller.forgery_protection_origin_check = false
  end
end

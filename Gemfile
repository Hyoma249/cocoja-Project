source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.5'
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"

gem "sprockets-rails"

gem "redis", "~> 5.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener"
  gem 'letter_opener_web'
end

group :test do
  # gem "capybara"
  # gem "selenium-webdriver"
end

# 追加 ⬇️
gem 'rack-cors'
# ユーザー機能
gem 'devise'
# 言語対応
gem 'rails-i18n'     # Rails の国際化対応
gem 'devise-i18n'    # devise の国際化対応
# 画像アップロード
gem 'carrierwave'
# 画像アップロードのストレージ
gem "cloudinary", "~> 2.3"
# Railsで非同期ジョブ（バックグラウンド処理）を実行するための定番ツール
gem 'sidekiq'
gem 'sidekiq-scheduler'

gem 'kaminari'  # ページネーション機能のベースとして使用
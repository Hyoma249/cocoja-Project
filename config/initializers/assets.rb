# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.paths << Rails.root.join('app/assets/builds')
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# application.cssに加え、Swiper関連のアセットも明示的にプリコンパイル対象に追加
Rails.application.config.assets.precompile += %w[
  application.css
  swiper-bundle.min.js
  swiper-bundle.min.css
]

# node_modules内のSwiperのCSSファイルを明示的に許可
Rails.application.config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif *.svg *.eot *.ttf *.woff *.woff2]
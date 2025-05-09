# MetaTags用の初期設定
MetaTags.configure do |config|
  # タイトルが指定されていない場合のデフォルトタイトル
  config.title_limit = 70

  # 説明文の文字数制限
  config.description_limit = 160

  # キーワードの制限（数）
  config.keywords_limit = 10

  # キーワードのセパレータ
  config.keywords_separator = ', '

  # OGPのimageがない場合のデフォルト画像
  config.og_image_default = 'cocoja-ogp.png'

  # Twitterカードタイプのデフォルト
  config.twitter_card_type = 'summary_large_image'

  # titleヘルパーメソッドで使用するセパレーター
  config.title_separator = ' | '
end

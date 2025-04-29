class ProfileImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # キャッシュディレクトリを明示的に指定
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # プロフィール画像をリサイズする
  process resize_to_limit: [ 800, 800 ]

  # サムネイル用のバージョンを作成
  version :thumb do
    process resize_to_fill: [ 200, 200 ]
  end

  # モバイル用の小さいサムネイル
  version :small do
    process resize_to_fill: [ 100, 100 ]
  end

  # 許可する拡張子
  def extension_allowlist
    %w[jpg jpeg gif png heic]
  end

  # デフォルト画像
  def default_url
    "sample_icon1.svg"
  end

  # 画像サイズの上限を指定
  def size_range
    1.byte..5.megabytes
  end
end

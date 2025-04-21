class PostImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # キャッシュディレクトリを明示的に指定
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # 画像をリサイズする（サムネイル用）
  process resize_to_limit: [1200, 1200]

  # サムネイル用のバージョンを作成
  version :thumb do
    process resize_to_fill: [400, 400]
  end

  # 画像ファイル形式
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # 画像サイズの上限を指定
  def size_range
    1.byte..5.megabytes
  end
end

class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave

  # storage :file

  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  # プロフィール画像用にリサイズ
  process resize_to_fill: [300, 300]

  # 許可する拡張子
  def extension_allowlist
    %w(jpg jpeg gif png heic)
  end

  # デフォルト画像
  def default_url
    "sample_icon1.svg"
  end
end

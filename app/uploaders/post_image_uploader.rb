class PostImageUploader < CarrierWave::Uploader::Base
  # Include RMagick, MiniMagick, or Vips support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  # process resize_to_fill: [400, 300]

  # 画像ファイル形式
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # 画像サイズの上限を指定
  def size_range
    1.byte..5.megabytes
  end
end

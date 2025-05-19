class ProfileImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def cache_dir
    Rails.root.join('tmp/uploads')
  end

  process resize_to_limit: [800, 800]

  version :thumb do
    process resize_to_fill: [200, 200]
  end

  version :small do
    process resize_to_fill: [100, 100]
  end

  def extension_allowlist
    %w[jpg jpeg gif png heic]
  end

  def default_url
    'sample_icon1.svg'
  end

  def size_range
    (1.byte)..(5.megabytes)
  end
end

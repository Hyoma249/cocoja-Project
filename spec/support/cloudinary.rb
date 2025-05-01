require 'cloudinary'

RSpec.configure do |config|
  config.before do
    # Cloudinaryのモック設定を強化
    Cloudinary.config do |c|
      c.cloud_name = 'test'
      c.api_key = 'test_key'
      c.api_secret = 'test_secret'
      c.secure = true
    end

    # アップロードのモックをより具体的に
    allow(Cloudinary::Uploader).to receive(:upload).and_return({
        'public_id' => 'test_image',
        'url' => 'http://example.com/test_image.jpg',
        'secure_url' => 'https://example.com/test_image.jpg',
        'width' => 800,
        'height' => 600,
        'resource_type' => 'image'
      })

    # 画像変換のモックも追加
    allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('https://example.com/test_image.jpg')
  end
end

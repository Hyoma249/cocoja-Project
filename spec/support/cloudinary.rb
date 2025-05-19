require 'cloudinary'

module CloudinaryHelper
  def stub_cloudinary_upload
    allow(Cloudinary::Uploader).to receive(:upload).and_return(
      {
        'public_id' => 'test_image',
        'url' => 'http://res.cloudinary.com/sample/image/upload/test_image.jpg',
        'secure_url' => 'https://res.cloudinary.com/sample/image/upload/test_image.jpg',
        'original_filename' => 'test_image.jpg'
      }
    )
  end

  def stub_cloudinary_destroy
    allow(Cloudinary::Uploader).to receive(:destroy).and_return({ 'result' => 'ok' })
  end
end

RSpec.configure do |config|
  config.include CloudinaryHelper

  config.before do
    Cloudinary.config do |c|
      c.cloud_name = 'test'
      c.api_key = 'test_key'
      c.api_secret = 'test_secret'
      c.secure = true
    end
    stub_cloudinary_upload
    allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('https://example.com/test_image.jpg')
  end
end

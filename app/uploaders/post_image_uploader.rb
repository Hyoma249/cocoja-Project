# 投稿画像のアップロードと加工を担当するアップローダー
class PostImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # キャッシュの最適化
  def cache_dir
    '/tmp/uploads'
  end

  # Cloudinaryのオプションとして回転情報を適用
  cloudinary_transformation angle: :exif

  # 品質設定のみ残す（既に最適化済みのため）
  process quality: 85
  
  # サムネイル用バージョンのみ最適化
  version :thumb do
    process resize_to_fill: [400, 400]
    process quality: 85
  end

  # 画像ファイル形式
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # 最大サイズ制限
  def size_range
    (1.byte)..(5.megabytes)
  end

  # 固定パスを使用することでURLの決定を高速化
  def public_id
    # オリジナルファイル名が保持されていない場合に備えて安全に処理
    secure_token = Digest::SHA1.hexdigest(Time.now.to_s + SecureRandom.uuid)
    
    if model && model.post_id
      return "posts/#{model.post_id}/#{secure_token[0..10]}"
    end
    
    # モデル情報がない場合のフォールバック
    "posts/tmp/#{secure_token}"
  end
  
  # 完全に修正したfilenameメソッド（警告を解消）
  def filename
    # 常に値を返すように修正（nilチェックを削除）
    extension = original_filename ? File.extname(original_filename).downcase : '.jpg'
    secure_token = Digest::SHA1.hexdigest("#{model.id}-#{Time.now.utc}-#{rand(1000)}")
    "#{secure_token[0..10]}#{extension}"
  end
end

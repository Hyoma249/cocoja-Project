CarrierWave.configure do |config|
  # 不要なオプションを削除し、パフォーマンスを向上
  config.cache_dir = Rails.root.join('tmp/uploads').to_s
  config.cache_storage = :file
  
  # 無駄なログ出力を抑制
  config.ignore_integrity_errors = true
  config.ignore_processing_errors = true
  config.ignore_download_errors = true
  
  # CarrierWaveの警告を抑制する設定
  # 存在しないメソッドなので削除または正しい設定に変更
  # config.validate_filename_format = false
  # 代わりに以下を使用
  config.validate_integrity = false
  
  # キャッシュを有効活用
  config.move_to_cache = true  # コピーの代わりにファイル移動を使用
  config.move_to_store = true
  
  if defined?(Cloudinary)
    # パフォーマンス最適化設定
    Cloudinary.config.timeout = 20
    Cloudinary.config.max_retries = 0 # リトライなし
    Cloudinary.config.max_threads = 2
    
    # アップロード高速化オプション
    Cloudinary.config.secure = true
    Cloudinary.config.cdn_subdomain = true
    Cloudinary.config.use_cache_only = true
    Cloudinary.config.optimize_image_encoding = true
    
    # 処理を軽量化
    Cloudinary.config.enhance_image_tag = false
    Cloudinary.config.static_file_support = false
    Cloudinary.config.eager_transformation = false
    
    # アップロード設定の最適化
    Cloudinary.config.resource_type = "auto"
    Cloudinary.config.unique_filename = true
    
    # 画像変換を最小限に
    Cloudinary.config.use_root_path = true
    Cloudinary.config.sign_url = false
  end
  
  # メモリ節約のための設定
  config.remove_previously_stored_files_after_update = true
end

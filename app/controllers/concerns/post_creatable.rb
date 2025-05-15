# 投稿作成に関連する機能を提供するモジュール
# 投稿の保存、画像処理、エラーハンドリング機能を担当します
require 'mini_magick'
require 'concurrent'

module PostCreatable
  extend ActiveSupport::Concern

  # 定数の定義
  MAX_IMAGES = 5

  private

  def save_post_with_images
    post_created = false
    
    ActiveRecord::Base.transaction do
      if @post.save
        post_created = true
        flash[:notice] = t('controllers.posts.create.success')
      else
        handle_failed_save
        return
      end
    end
    
    # トランザクションの外で画像処理を実行
    if post_created
      begin
        # 画像処理を実行 - バッチ処理で効率化
        process_image_upload
      rescue => e
        # エラーがあっても投稿自体は既に保存済み
        Rails.logger.error("画像処理エラー: #{e.message}")
        flash[:alert] = "一部の画像のアップロードに失敗しました。投稿は保存されています。"
      end
      
      # 投稿成功後のリダイレクト
      redirect_to posts_url and return
    end
  rescue StandardError => e
    @prefectures = Prefecture.all
    flash.now[:alert] = "投稿に失敗しました: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  # 高速化した画像処理
  def process_image_upload
    return unless params[:post_images].present? && params[:post_images][:image].present?
    
    # 空の画像を除外
    image_files = params[:post_images][:image].reject(&:blank?)
    return if image_files.blank?
    
    # 画像数を先に設定
    total_images = image_files.size
    @post.update_column(:post_images_count, 0) # 一旦0に設定
    
    # 先行最適化による高速化
    optimized_images = []
    image_files.each_with_index do |file, index|
      begin
        optimized_file = optimize_image_fast(file)
        optimized_images << { file: optimized_file, index: index }
      rescue => e
        Rails.logger.error("画像#{index}の最適化に失敗: #{e.message}")
      end
    end
    
    # 最適化完了後にアップロード処理
    processed_count = 0
    
    # 高速化のための設定
    Cloudinary.config.max_threads = [optimized_images.size, 2].min
    Cloudinary.config.timeout = 20
    
    # バッチ処理 - 直列数を増やして処理負荷を軽減
    optimized_images.each do |item|
      begin
        # アップロードのみを行いDB更新は最小限に
        post_image = @post.post_images.new
        post_image.image = item[:file]
        
        if post_image.save
          processed_count += 1
          # カウンターキャッシュを使用して更新を減らす（1回のみ更新）
          @post.post_images_count = processed_count
          Rails.logger.info("画像 #{processed_count}/#{total_images} アップロード完了: ID=#{post_image.id}")
        end
      rescue => e
        Rails.logger.error("画像#{item[:index]}アップロードエラー: #{e.message}")
      end
    end
    
    # 最終的なカウンター更新（1回だけ）
    @post.update_column(:post_images_count, processed_count) if processed_count > 0
  end

  # 高速化した画像最適化 - 最小限の処理だけを実行
  def optimize_image_fast(image)
    return image unless image.present? && image.tempfile.present?
    
    begin
      # 小さなファイルは最適化しない
      return image if image.size < 500.kilobytes
      
      temp_file = Tempfile.new(['opt', File.extname(image.original_filename).presence || '.jpg'], binmode: true)
      
      # 必要最小限の処理だけを実行
      MiniMagick::Tool::Convert.new do |convert|
        convert << image.tempfile.path
        convert.strip # メタデータ削除
        convert.auto_orient # 向き補正
        convert.resize("1200x1200>") # サイズ制限
        convert.quality(85) # 品質設定
        convert << temp_file.path
      end
      
      # 最適化済み画像を返却
      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: image.original_filename,
        type: image.content_type
      )
    rescue => e
      Rails.logger.error("画像最適化エラー: #{e.message}")
      image # エラーの場合は元画像を使用
    end
  end

  # エラーハンドリング
  def handle_failed_save
    @prefectures = Prefecture.all
    error_messages = []
    error_messages.concat(@post.errors.full_messages) if @post.errors.any?
    flash.now[:alert] = error_messages.present? ? error_messages.join(', ') : t('controllers.posts.create.failure')
    render :new, status: :unprocessable_entity
  end

  def max_images_exceeded?
    return false unless params[:post_images] && params[:post_images][:image].present?
    params[:post_images][:image].compact_blank.count > MAX_IMAGES
  end

  def handle_max_images_exceeded
    @prefectures = Prefecture.all
    flash.now[:notice] = t('controllers.posts.create.max_images', count: MAX_IMAGES)
    render :new, status: :unprocessable_entity
  end
end

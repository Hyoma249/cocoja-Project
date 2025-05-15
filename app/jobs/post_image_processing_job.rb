class PostImageProcessingJob < ApplicationJob
  queue_as :default
  
  # 複数の処理方法をサポート
  # 1. post_id + file_paths形式（新方式）
  # 2. post_image_data形式（旧方式）
  def perform(first_arg, second_arg = nil)
    if second_arg.nil?
      # 旧形式: post_image_data のみの呼び出し
      process_temp_images(first_arg)
    else
      # 新形式: post_id + file_paths の呼び出し
      process_file_paths(first_arg, second_arg)
    end
  end
  
  private
  
  # 新形式: 直接ファイルパスから処理（最適化版）
  def process_file_paths(post_id, file_paths)
    return if post_id.blank? || file_paths.blank?
    
    post = Post.find_by(id: post_id)
    return unless post
    
    # 並列処理の制限
    max_threads = [file_paths.size, 3].min
    Cloudinary.config.max_threads = max_threads if defined?(Cloudinary)
    
    # 処理完了数
    processed_count = 0
    
    # バッチサイズ
    batch_size = 2
    
    # バッチ単位で処理
    file_paths.each_slice(batch_size) do |batch|
      batch.each do |file_path|
        begin
          # ファイルの存在確認
          unless File.exist?(file_path)
            Rails.logger.error("ファイルが見つかりません: #{file_path}")
            next
          end
          
          # タイムアウト設定で画像アップロード
          Timeout.timeout(30) do
            # 画像レコード作成
            post_image = post.post_images.new
            post_image.image = File.open(file_path)
            
            if post_image.save
              processed_count += 1
              Rails.logger.info("バックグラウンド画像処理完了: ID=#{post_image.id}")
            else
              Rails.logger.error("画像保存エラー: #{post_image.errors.full_messages.join(', ')}")
            end
          end
        rescue Timeout::Error
          Rails.logger.error("画像処理がタイムアウトしました: #{file_path}")
        rescue => e
          Rails.logger.error("バックグラウンド画像処理エラー: #{e.message}")
        ensure
          # 一時ファイルをクリーンアップ
          File.delete(file_path) if File.exist?(file_path)
        end
      end
    end
    
    # 投稿の画像カウンターを更新
    post.update_column(:post_images_count, processed_count) if post.respond_to?(:post_images_count)
  end
  
  # 旧形式: TempPostImageモデルからの処理
  def process_temp_images(post_image_data)
    return if post_image_data.blank?
    
    processed_posts = {}
    
    post_image_data.each do |data|
      begin
        # データ構造を確認して処理
        post_image_id = data[:id] || data["id"]
        temp_image_id = data[:temp_image_id] || data["temp_image_id"]
        
        post_image = PostImage.find_by(id: post_image_id)
        temp_image = TempPostImage.find_by(id: temp_image_id)
        
        next if post_image.nil? || temp_image.nil?
        
        # 投稿IDを記録（カウンター更新用）
        post_id = post_image.post_id
        processed_posts[post_id] ||= 0
        
        # 一時ファイルが存在するか確認
        unless temp_image.file_exists?
          Rails.logger.error("一時ファイルが見つかりません: #{temp_image.file_path}")
          next
        end
        
        # CarrierWaveでファイルをアップロード
        file = temp_image.file
        post_image.image = file
        
        if post_image.save
          processed_posts[post_id] += 1
          Rails.logger.info("バックグラウンド画像処理完了: ID=#{post_image.id}")
        else
          Rails.logger.error("画像保存エラー: #{post_image.errors.full_messages.join(', ')}")
        end
      rescue => e
        Rails.logger.error("バックグラウンド画像処理エラー: #{e.message}")
      ensure
        # 一時ファイルとレコードをクリーンアップ
        temp_image&.destroy
      end
    end
    
    # 各投稿の画像カウンターを更新
    processed_posts.each do |post_id, count|
      post = Post.find_by(id: post_id)
      next unless post && post.respond_to?(:post_images_count)
      
      current_count = post.post_images.count
      post.update_column(:post_images_count, current_count)
    end
  end
end
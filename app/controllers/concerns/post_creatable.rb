# 投稿作成に関連する機能を提供するモジュール
# 投稿の保存、画像処理、エラーハンドリング機能を担当します
module PostCreatable
  extend ActiveSupport::Concern

  # 定数の定義
  MAX_IMAGES = 10

  private

  def save_post_with_images
    ActiveRecord::Base.transaction do
      if @post.save
        process_uploaded_images
        flash[:notice] = t('controllers.posts.create.success')
        redirect_to posts_url(protocol: 'https') and return
      else
        handle_failed_save
      end
    end
  rescue StandardError => e
    Rails.logger.error("投稿作成エラー: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @prefectures = Prefecture.all
    flash.now[:alert] = "投稿に失敗しました: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def process_uploaded_images
    return unless params[:post_images] && params[:post_images][:image].present?

    images_to_process = params[:post_images][:image].compact_blank
    images_to_process.each do |image|
      # create! ではなく create を使用し、エラーをチェック
      post_image = @post.post_images.create(image: image)
      unless post_image.persisted?
        error_message = post_image.errors.full_messages.join(', ')
        raise StandardError, error_message
      end
    end
  end

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

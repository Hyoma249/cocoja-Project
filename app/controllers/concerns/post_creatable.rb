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
        redirect_to posts_url(protocol: 'https')
      else
        handle_failed_save
      end
    end
  end

  def process_uploaded_images
    return unless params[:post_images] && params[:post_images][:image].present?

    images_to_process = params[:post_images][:image].compact_blank
    images_to_process.each do |image|
      @post.post_images.create!(image: image)
    end
  end

  def handle_failed_save
    @prefectures = Prefecture.all
    flash.now[:notice] = t('controllers.posts.create.failure')
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

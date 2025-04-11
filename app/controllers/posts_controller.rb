class PostsController < ApplicationController
  # ログインユーザーによってのみ実行可能となる
  before_action :authenticate_user!
  include PostsHelper

  def index
    @user = current_user
    @posts = Post.includes(:prefecture, :user, :hashtags).order(created_at: :desc)

    if params[:name].present?
      @tag = Hashtag.find_by(name: params[:name])
      @posts = @posts.joins(:hashtags).where(hashtags: { name: params[:name] }) if @tag
    end
  end

  # 「新しい投稿を作成」ボタンを押したときに実行される
  def new
    # 「新しい投稿（Post）を作る準備」 をしている
    @post = Post.new
    # 「都道府県のリストを全部取り出す」 ためのコード
    @prefectures = Prefecture.all
    # 投稿に紐づいた画像フォームを出すために、空の子モデル（PostImage）を作っておく処理
    @post.post_images.build
  end

  # submitボタンを押したときに実行される
  def create
    # ログインしているユーザーの投稿を作成する
    @post = current_user.posts.build(post_params)
    # 画像数のチェック
    max_images = 10
    if params[:post_images] && params[:post_images][:image].present?
      if params[:post_images][:image].select {|img| img.present? }.count > max_images
        @prefectures = Prefecture.all
        flash.now[:notice] = "画像は最大#{max_images}枚までになります"
        render :new, status: :unprocessable_entity
        return
      end
    end

    if @post.save
      if params[:post_images] && params[:post_images][:image].present?
        params[:post_images][:image].each do |image|
          next if image.blank?
          begin
            Rails.logger.info("画像アップロード開始: キャッシュディレクトリ=#{CarrierWave.configure.cache_dir}")
            Rails.logger.info("画像情報: クラス=#{image.class.name}, サイズ=#{image.size if image.respond_to?(:size)}")

            image_record = @post.post_images.build
            image_record.image = image
            image_record.save!

            Rails.logger.info("画像アップロード成功: ID=#{image_record.id}, URL=#{image_record.image.url}")
          rescue => e
            Rails.logger.error("画像アップロード失敗: #{e.class.name} - #{e.message}")
            Rails.logger.error(e.backtrace.join("\n"))
          end
        end
      end
      flash[:notice] = "投稿が作成されました"
      redirect_to posts_path
    else
      @prefectures = Prefecture.all
      flash.now[:notice] = "投稿の作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def hashtag
    @user = current_user
    @tag = Hashtag.find_by(name: params[:name])

    if @tag
      @posts = @tag.posts.includes(:prefecture, :user, :hashtags).order(created_at: :desc)
    else
      redirect_to posts_path, notice: "該当する投稿がありません"
    end
  end

  private

  def post_params
    params.require(:post).permit(:prefecture_id, :content, post_images_attributes: [:image] )
  end
end

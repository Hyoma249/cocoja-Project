class PostsController < ApplicationController
  # ログインユーザーによってのみ実行可能となる
  before_action :authenticate_user!
  include PostsHelper

  def index
    @user = current_user
    # 基本のクエリを構築
    base_query = Post.includes(:prefecture, :user, :hashtags, :post_images)
                   .order(created_at: :desc)

    # タグフィルタリング
    if params[:name].present?
      @tag = Hashtag.find_by(name: params[:name])
      if @tag
        base_query = base_query.joins(:hashtags).where(hashtags: { name: params[:name] })
      end
    end

    # slideパラメータを使用してページネーション
    @posts = base_query.page(params[:slide]).per(12)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @post = Post.find(params[:id])
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
      if params[:post_images][:image].select { |img| img.present? }.count > max_images
        @prefectures = Prefecture.all
        flash.now[:notice] = "画像は最大#{max_images}枚までになります"
        render :new, status: :unprocessable_entity
        return
      end
    end

    # トランザクションでまとめて処理
    ActiveRecord::Base.transaction do
      if @post.save
        if params[:post_images] && params[:post_images][:image].present?
          # 画像を一括でメモリに読み込み、順次処理
          images_to_process = params[:post_images][:image].select { |img| img.present? }

          images_to_process.each do |image|
            # 画像を最適化してから保存（先に読み込むことでI/O待ちを減らす）
            @post.post_images.create!(image: image)
          end
        end

        flash[:notice] = "投稿が作成されました"
        redirect_to posts_url(protocol: "https")
      else
        @prefectures = Prefecture.all
        flash.now[:notice] = "投稿の作成に失敗しました"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def hashtag
    @user = current_user
    @tag = Hashtag.find_by(name: params[:name])

    if @tag
      # 基本クエリを構築
      base_query = @tag.posts.includes(:prefecture, :user, :hashtags, :post_images)
                       .order(created_at: :desc)

      # ページネーションを適用
      @posts = base_query.page(params[:page]).per(12)

      respond_to do |format|
        format.html
        format.json do
          render json: {
            posts: @posts.as_json(
              include: [
                { user: { only: [ :uid ], methods: [ :profile_image_url ] } },
                { prefecture: { only: [ :name ] } },
                { hashtags: { only: [ :name ] } },
                { post_images: { only: [], methods: [ :image ] } }
              ],
              methods: [ :created_at_formatted ]
            ),
            next_page: @posts.next_page.present?
          }
        end
      end
    else
      redirect_to posts_url(protocol: "https"), notice: "該当する投稿がありません"
    end
  end

  private

  def post_params
    params.require(:post).permit(:prefecture_id, :content, post_images_attributes: [ :image ])
  end
end

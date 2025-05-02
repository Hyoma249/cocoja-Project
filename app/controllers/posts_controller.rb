# 投稿（Post）に関する操作を担当するコントローラー
# 投稿の表示、作成、編集、削除やハッシュタグ検索機能を提供します
class PostsController < ApplicationController
  # ログインユーザーによってのみ実行可能となる
  before_action :authenticate_user!
  include PostsHelper
  include PostsJsonBuildable
  include PostCreatable

  # 定数の定義
  MAX_IMAGES = 10
  POSTS_PER_PAGE = 12

  def index
    @user = current_user
    load_posts_with_filters

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
    @post = current_user.posts.build(post_params)

    return handle_max_images_exceeded if max_images_exceeded?

    save_post_with_images
  end

  def hashtag
    @user = current_user
    @tag = Hashtag.find_by(name: params[:name])

    if @tag
      load_hashtag_posts
      render_response
    else
      redirect_to posts_url(protocol: 'https'), notice: t('controllers.posts.hashtag.not_found')
    end
  end

  private

  def post_params
    params.require(:post).permit(:prefecture_id, :content, post_images_attributes: [:image])
  end

  def load_posts_with_filters
    @posts = build_base_query
    filter_by_hashtag if params[:name].present?
    apply_pagination
  end

  def build_base_query
    Post.includes(:prefecture, :user, :hashtags, :post_images)
        .order(created_at: :desc)
  end

  def filter_by_hashtag
    @tag = Hashtag.find_by(name: params[:name])
    @posts = @posts.joins(:hashtags).where(hashtags: { name: params[:name] }) if @tag
  end

  def apply_pagination
    @posts = @posts.page(params[:slide]).per(POSTS_PER_PAGE)
  end

  def load_hashtag_posts
    @posts = @tag.posts
                 .includes(:prefecture, :user, :hashtags, :post_images)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(POSTS_PER_PAGE)
  end

  def render_response
    respond_to do |format|
      format.html
      format.json { render json: build_posts_json }
    end
  end
end

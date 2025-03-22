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
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
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
    params.require(:post).permit(:prefecture_id, :content)
  end
end

class PostsController < ApplicationController
  # ログインユーザーによってのみ実行可能となる
  before_action :authenticate_user!

  def index
    @posts = Post.includes(:prefecture, :user).order(created_at: :desc)
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

  private

  def post_params
    params.require(:post).permit(:prefecture_id, :content)
  end
end

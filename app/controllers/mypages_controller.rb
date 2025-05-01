class MypagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :edit, :update ]

  def show
    # 基本クエリを構築
    base_query = @user.posts.includes(:post_images).order(created_at: :desc)

    # ページネーションを適用
    @posts = base_query.page(params[:slide]).per(12)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to mypage_url(protocol: "https"), notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :uid, :bio, :profile_image_url, :profile_image_url_cache)
  end
end

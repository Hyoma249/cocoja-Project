class MypagesController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  def show
    @posts = @user.posts.includes(:post_images).order(created_at: :desc)
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to mypage_path, notice: 'プロフィールを更新しました'
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

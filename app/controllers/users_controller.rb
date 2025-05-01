class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :following, :followers]

  def show
    @user = User.find_by!(id: params[:id])
    @posts = @user.posts.order(created_at: :desc).page(params[:page])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "ユーザーが見つかりません"
    redirect_to user_path
  end

  def following
    @title = "フォロー中"
    @users = @user.followings.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = "フォロワー"
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private

  def set_user
    @user = User.find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "ユーザーが見つかりません"
    redirect_to user_path
  end
end

# ユーザー（User）に関する操作を担当するコントローラー
# ユーザープロフィール表示、フォロー/フォロワー管理機能を提供します
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show following followers]

  def show
    @posts = @user.posts.includes(:post_images).order(created_at: :desc).page(params[:page]).per(9)

    respond_to do |format|
      format.html
      format.json { render json: { posts: @posts } }
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('controllers.users.not_found')
    redirect_to user_path
  end

  def following
    @title = t('controllers.users.following.title')
    @users = @user.followings.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = t('controllers.users.followers.title')
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('controllers.users.not_found')
    redirect_to user_path
  end
end

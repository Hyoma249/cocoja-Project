class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def setup
    @user = current_user
    @google_connected = @user.provider == 'google_oauth2' && @user.uid_from_provider.present?
  end

  def update
    @user = current_user

    if @user.update(user_params)
      flash[:notice] = 'プロフィールを更新しました'
      redirect_to top_page_login_url(protocol: 'https')
    else
      flash.now[:alert] = '入力内容に誤りがあります'
      render :setup, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :uid, :bio, :profile_image_url)
  end
end

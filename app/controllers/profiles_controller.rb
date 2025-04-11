class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def setup
    # 現在ログインしているユーザー情報を格納している
    @user = current_user
  end

  def update
    @user = current_user
    Rails.logger.debug "更新パラメータ: #{profile_params.inspect}"

    if @user.update(profile_params)
      redirect_to top_page_login_path, notice: "プロフィールが登録されました"
    else
      flash.now[:notice] = "プロフィール登録に失敗しました"
      render :setup, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :uid)
  end
end

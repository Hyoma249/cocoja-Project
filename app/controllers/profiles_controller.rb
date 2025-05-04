# プロフィール（Profile）に関する操作を担当するコントローラー
# ユーザープロフィールの設定と更新機能を提供します
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def setup
    @user = current_user
  end

  def update
    @user = current_user
    Rails.logger.debug { "更新パラメータ: #{profile_params.inspect}" }

    if @user.update(profile_params)
      redirect_to top_page_login_url(protocol: 'https'),
                  notice: t('controllers.profiles.update.success')
    else
      flash.now[:notice] = t('controllers.profiles.update.failure')
      render :setup, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :uid)
  end
end

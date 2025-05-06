# プロフィール（Profile）に関する操作を担当するコントローラー
# ユーザープロフィールの設定と更新機能を提供します
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def setup
    # 既存のuidやusernameがあれば初期値として表示
    @user = current_user

    # Googleアカウント連携済みかどうかを確認
    @google_connected = @user.provider == 'google_oauth2' && @user.uid_from_provider.present?
  end

  def update
    @user = current_user

    if @user.update(user_params)
      # フォローすべきユーザーがいればフォロー処理を行う（オプション）

      flash[:notice] = 'プロフィールを更新しました'
      redirect_to top_page_login_url(protocol: 'https') # ログイン後のトップページへ
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

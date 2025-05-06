# 外部認証サービス連携に関する操作を担当するコントローラー
# OAuth認証機能を提供します
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Googleログイン認証のコールバック処理
    def google_oauth2
      handle_auth("Google")
    end

    private

    def handle_auth(kind)
      # auth情報からユーザーを検索または作成
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        # 認証成功の場合
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind

        # ユーザー名やuidが未設定の場合は、プロフィール設定画面へ
        if @user.username.blank? || @user.uid.blank?
          sign_in @user, event: :authentication
          redirect_to profile_setup_path
        else
          # 既存ユーザーの場合は通常のログインフロー
          sign_in_and_redirect @user, event: :authentication
        end
      else
        # 認証失敗の場合、セッションにデータを格納して登録画面へ
        session["devise.#{kind.downcase}_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end
  end
end

# ユーザー認証（セッション）に関する操作を担当するコントローラー
# ログイン、ログアウト機能を提供します
module Users
  # Deviseのセッションコントローラーを拡張し、カスタムログイン/ログアウト機能を提供します
  class SessionsController < Devise::SessionsController
    # DELETE /resource/sign_out
    def destroy
      super do
        return redirect_to root_url(protocol: 'https'), notice: t('controllers.users.sessions.signed_out')
      end
    end

    protected

    def after_sign_in_path_for(_resource)
      flash[:notice] = t('controllers.users.sessions.signed_in')
      top_page_login_url(protocol: 'https')
    end
  end
end
